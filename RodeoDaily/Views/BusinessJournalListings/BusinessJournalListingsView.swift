import SwiftUI

struct BusinessJournalListingsView: View {
    enum SortOption: String, CaseIterable, Identifiable {
        case eventSoonest = "Event Date (Soonest)"
        case eventLatest = "Event Date (Latest)"
        case addedMoneyHigh = "Added Money (High-Low)"
        case addedMoneyLow = "Added Money (Low-High)"

        var id: String { rawValue }
    }

    enum DateFilterMode: String, CaseIterable, Identifiable {
        case all = "All Dates"
        case month = "Month"
        case range = "Date Range"

        var id: String { rawValue }
    }

    let items: [BusinessJournalFeedItem]
    let loading: Bool
    let errorMessage: String?
    let searchText: String
    let reload: () async -> Void

    @State private var sortOption: SortOption = .eventSoonest
    @State private var dateFilterMode: DateFilterMode = .all
    @State private var selectedMonthKey: String?
    @State private var rangeStartDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var rangeEndDate = Date.now
    @State private var showingDateRangeSheet = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                disclaimerCard
                filterControls

                Group {
                    if loading && items.isEmpty {
                        LazyVStack(spacing: 10) {
                            ForEach(0..<6, id: \.self) { _ in
                                BusinessJournalFeedCardSkeleton()
                            }
                        }
                    } else if visibleItems.isEmpty {
                        ContentUnavailableView {
                            Label("No Rodeos", systemImage: "newspaper")
                        } description: {
                            Text(errorMessage ?? "There are no matching rodeos right now.")
                        } actions: {
                            Button("Retry") {
                                Task { await reload() }
                            }
                        }
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                                if AdPlacementPolicy.shouldShowListAd(beforeItemAt: index) {
                                    BannerAd(placement: .rodeoListingsList)
                                }

                                NavigationLink {
                                    BusinessJournalListingDetailView(item: item)
                                } label: {
                                    BusinessJournalFeedCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }

                            if AdPlacementPolicy.shouldShowBottomAd(itemCount: visibleItems.count) {
                                BannerAd(placement: .rodeoListingsList)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, AppSpace.xxl)
        }
        .refreshable {
            await reload()
        }
        .sheet(isPresented: $showingDateRangeSheet) {
            dateRangeSheet
        }
        .onChange(of: dateFilterMode) { _, newValue in
            if newValue == .month && selectedMonthKey == nil {
                selectedMonthKey = monthOptions.first?.0
            }
        }
        .onAppear {
            AnalyticsService.shared.track(.rodeoListingsViewed)
        }
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            HStack(alignment: .top, spacing: AppSpace.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
//                    .font(.caption)
                    .padding(.top, 2)

                Text(NSLocalizedString("Listings shown here are unofficial and may be incomplete or delayed. Visit the official site below for official listings.", comment: ""))
                    .font(.appBody)
                    .foregroundColor(.appPrimary)
            }

            Link(destination: URL(string: "https://pbj.prorodeo.org/")!) {
                HStack(spacing: AppSpace.xs) {
                    Image(systemName: "arrow.up.right.square")
                    Text(NSLocalizedString("Official PRCA Business Journal Listings", comment: ""))
                        .font(.appBodyStrong)
                }
                .foregroundColor(.appSecondary)
            }
            .buttonStyle(.plain)
        }
        .appCardStyle()
    }

    private var filterControls: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace.sm) {
                filterMenuChip(title: "Sort", value: sortOption.rawValue) {
                    ForEach(SortOption.allCases) { option in
                        Button(option.rawValue) {
                            sortOption = option
                        }
                    }
                }

                filterMenuChip(title: "Date Filter", value: dateFilterValue) {
                    Button(DateFilterMode.all.rawValue) {
                        dateFilterMode = .all
                    }

                    Menu {
                        Button("All Months") {
                            dateFilterMode = .month
                            selectedMonthKey = nil
                        }

                        ForEach(monthOptions, id: \.0) { option in
                            Button(option.1) {
                                dateFilterMode = .month
                                selectedMonthKey = option.0
                            }
                        }
                    } label: {
                        if dateFilterMode == .month, let selectedMonthLabel {
                            Text("Month: \(selectedMonthLabel)")
                        } else {
                            Text("Month")
                        }
                    }

                    Button("Date Range") {
                        dateFilterMode = .range
                        showingDateRangeSheet = true
                    }

                    if dateFilterMode == .range {
                        Button("Edit Date Range") {
                            showingDateRangeSheet = true
                        }
                    }
                }

            }
        }
    }

    private var visibleItems: [BusinessJournalFeedItem] {
        sort(filteredByDate(filteredBySearch(items)))
    }

    private var monthOptions: [(String, String)] {
        var seen = Set<String>()
        var values = [(String, String)]()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM yyyy"

        for item in items {
            guard let date = sortDate(for: item) else { continue }
            let components = calendar.dateComponents([.year, .month], from: date)
            guard let year = components.year, let month = components.month else { continue }
            let key = String(format: "%04d-%02d", year, month)
            guard !seen.contains(key) else { continue }
            seen.insert(key)

            guard let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { continue }
            values.append((key, formatter.string(from: monthDate)))
        }

        return values.sorted(by: { $0.0 > $1.0 })
    }

    private var selectedMonthLabel: String? {
        guard let selectedMonthKey else { return nil }
        return monthOptions.first(where: { $0.0 == selectedMonthKey })?.1
    }

    private var dateFilterValue: String {
        switch dateFilterMode {
        case .all:
            return DateFilterMode.all.rawValue
        case .month:
            return selectedMonthLabel ?? "All Months"
        case .range:
            return "Date Range"
        }
    }

    private func filteredBySearch(_ source: [BusinessJournalFeedItem]) -> [BusinessJournalFeedItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return source }

        return source.filter { item in
            item.title.localizedCaseInsensitiveContains(trimmed)
            || (item.subtitle?.localizedCaseInsensitiveContains(trimmed) ?? false)
            || (item.locationText?.localizedCaseInsensitiveContains(trimmed) ?? false)
            || (item.eventsText?.localizedCaseInsensitiveContains(trimmed) ?? false)
            || (item.source?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }

    private func filteredByDate(_ source: [BusinessJournalFeedItem]) -> [BusinessJournalFeedItem] {
        switch dateFilterMode {
        case .all:
            return source
        case .month:
            guard let selectedMonthKey else { return source }
            let split = selectedMonthKey.split(separator: "-")
            guard split.count == 2,
                  let year = Int(split[0]),
                  let month = Int(split[1]) else {
                return source
            }

            let calendar = Calendar.current
            guard let start = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                  let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) else {
                return source
            }

            return source.filter { item in
                overlaps(item: item, from: start, to: end)
            }
        case .range:
            let start = min(rangeStartDate, rangeEndDate)
            let end = max(rangeStartDate, rangeEndDate)
            return source.filter { item in
                overlaps(item: item, from: start, to: end)
            }
        }
    }

    private func sort(_ source: [BusinessJournalFeedItem]) -> [BusinessJournalFeedItem] {
        source.sorted { lhs, rhs in
            switch sortOption {
            case .eventSoonest:
                return compareDateItems(lhs, rhs, ascending: true)
            case .eventLatest:
                return compareDateItems(lhs, rhs, ascending: false)
            case .addedMoneyHigh:
                return compareMoneyItems(lhs, rhs, ascending: false)
            case .addedMoneyLow:
                return compareMoneyItems(lhs, rhs, ascending: true)
            }
        }
    }

    private func compareDateItems(_ lhs: BusinessJournalFeedItem, _ rhs: BusinessJournalFeedItem, ascending: Bool) -> Bool {
        let leftDate = sortDate(for: lhs)
        let rightDate = sortDate(for: rhs)

        switch (leftDate, rightDate) {
        case let (l?, r?):
            if l != r {
                return ascending ? l < r : l > r
            }
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            break
        }

        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }

    private func compareMoneyItems(_ lhs: BusinessJournalFeedItem, _ rhs: BusinessJournalFeedItem, ascending: Bool) -> Bool {
        switch (lhs.addedMoneyTotal, rhs.addedMoneyTotal) {
        case let (l?, r?):
            if l != r {
                return ascending ? l < r : l > r
            }
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            break
        }

        return compareDateItems(lhs, rhs, ascending: true)
    }

    private func overlaps(item: BusinessJournalFeedItem, from start: Date, to end: Date) -> Bool {
        let itemStart = item.eventStartDate ?? item.eventEndDate ?? item.eventSortDate
        let itemEnd = item.eventEndDate ?? item.eventStartDate ?? item.eventSortDate
        guard let itemStart, let itemEnd else { return false }
        return itemStart <= end && itemEnd >= start
    }

    private func sortDate(for item: BusinessJournalFeedItem) -> Date? {
        item.eventSortDate
    }

    private func filterMenuChip<Content: View>(
        title: String,
        value: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Menu(content: content) {
            chipContent(title: title, value: value, trailingSystemImage: "chevron.down")
        }
    }

    private func chipContent(title: String, value: String, trailingSystemImage: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.xxs) {
            Text(title.uppercased())
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)

            HStack(spacing: AppSpace.xs) {
                Text(value)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                    .lineLimit(1)

                Image(systemName: trailingSystemImage)
                    .font(.caption2)
                    .foregroundColor(.appSecondary)
            }
        }
        .padding(.vertical, AppSpace.sm)
        .padding(.horizontal, AppSpace.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(Color.appBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
        )
    }

    private var dateRangeSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                SwiftUI.DatePicker(
                    "Start Date",
                    selection: $rangeStartDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)

                SwiftUI.DatePicker(
                    "End Date",
                    selection: $rangeEndDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)

                HStack(spacing: AppSpace.sm) {
                    Button("Clear") {
                        let today = Date.now
                        rangeStartDate = Calendar.current.date(byAdding: .month, value: -1, to: today) ?? today
                        rangeEndDate = today
                        dateFilterMode = .all
                        showingDateRangeSheet = false
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Apply") {
                        dateFilterMode = .range
                        showingDateRangeSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Date Range")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}
