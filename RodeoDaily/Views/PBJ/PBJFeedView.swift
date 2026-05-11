import SwiftUI

struct PBJFeedView: View {
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

    let items: [PBJFeedItem]
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
                                PBJFeedCardSkeleton()
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
                            ForEach(visibleItems) { item in
                                NavigationLink {
                                    PBJFeedDetailView(item: item)
                                } label: {
                                    PBJFeedCard(item: item)
                                }
                                .buttonStyle(.plain)
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

    private var visibleItems: [PBJFeedItem] {
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

    private func filteredBySearch(_ source: [PBJFeedItem]) -> [PBJFeedItem] {
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

    private func filteredByDate(_ source: [PBJFeedItem]) -> [PBJFeedItem] {
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

    private func sort(_ source: [PBJFeedItem]) -> [PBJFeedItem] {
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

    private func compareDateItems(_ lhs: PBJFeedItem, _ rhs: PBJFeedItem, ascending: Bool) -> Bool {
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

    private func compareMoneyItems(_ lhs: PBJFeedItem, _ rhs: PBJFeedItem, ascending: Bool) -> Bool {
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

    private func overlaps(item: PBJFeedItem, from start: Date, to end: Date) -> Bool {
        let itemStart = item.eventStartDate ?? item.eventEndDate ?? item.eventSortDate
        let itemEnd = item.eventEndDate ?? item.eventStartDate ?? item.eventSortDate
        guard let itemStart, let itemEnd else { return false }
        return itemStart <= end && itemEnd >= start
    }

    private func sortDate(for item: PBJFeedItem) -> Date? {
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

private struct PBJFeedCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.20))
                .frame(height: 20)
                .frame(maxWidth: 210, alignment: .leading)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.16))
                .frame(height: 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: AppSpace.xs) {
                capsule(width: 110)
                capsule(width: 100)
            }

            HStack(spacing: AppSpace.xs) {
                capsule(width: 90)
                capsule(width: 120)
            }

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.16))
                .frame(height: 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.16))
                .frame(height: 16)
                .frame(maxWidth: 260, alignment: .leading)
        }
        .redacted(reason: .placeholder)
        .appCardStyle()
    }

    private func capsule(width: CGFloat) -> some View {
        Capsule()
            .fill(Color.appTertiary.opacity(0.18))
            .frame(width: width, height: 24)
    }
}

private struct PBJFeedCard: View {
    private struct TourBadgeStyle {
        let foreground: Color
        let start: Color
        let end: Color
        let border: Color
        let icon: String
    }

    let item: PBJFeedItem

    var body: some View {
        rowContent
            .appCardStyle()
    }

    private var rowContent: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(item.title)
                .foregroundStyle(Color.appPrimary)
                .font(.appCardTitle)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if let subtitle = item.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .foregroundStyle(Color.appSecondary)
                    .font(.appBody)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }

            if let source = item.source,
               let displayTour = displayTourLabel(from: source) {
                tourBadge(displayTour)
            }

            HStack(spacing: AppSpace.xs) {
                if let dateText = item.dateText, !dateText.isEmpty {
                    chip(icon: "calendar", text: dateText, color: .appSecondary)
                }
                
                if let locationText = item.locationText, !locationText.isEmpty {
                    chip(icon: "mappin.and.ellipse", text: locationText, color: .appSecondary)
                }
            }
            
            HStack(spacing: AppSpace.xs) {
                if let statusText = item.statusText, !statusText.isEmpty {
                    chip(icon: "flag", text: statusText, color: .appTertiary)
                }

                if let perfsText = item.perfsText, !perfsText.isEmpty {
                    chip(icon: "person.3", text: perfsText, color: .appSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTertiary)
                    .font(.caption)
            }
            
            if let eventsText = item.eventsText, !eventsText.isEmpty {
                Text(eventsText)
                    .font(.appBody)
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if let specialFeesText = item.specialEntryFeesText, !specialFeesText.isEmpty {
                (
                    Text("Special Entry Fees: ")
                        .font(.appBodyStrong)
                        .foregroundStyle(Color.appPrimary)
                    +
                    Text(specialFeesText)
                        .font(.appBody)
                        .foregroundStyle(Color.appPrimary)
                )
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func chip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.appCaptionStrong)
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppSpace.xs)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.appBg.opacity(0.55))
        )
    }

    private func tourBadge(_ source: String) -> some View {
        let style = styleForTour(source)
        return HStack(spacing: AppSpace.xs) {
//            Image(systemName: style.icon)
//                .font(.caption2.weight(.bold))
            Text(source.uppercased())
                .font(.appCaptionStrong.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(style.foreground)
        .padding(.vertical, 6)
        .padding(.horizontal, AppSpace.sm)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [style.start, style.end],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(style.border, lineWidth: AppStroke.hairline)
        )
    }

    private func styleForTour(_ source: String) -> TourBadgeStyle {
        let token = source.lowercased()

        if token == "cn" || token.contains("canada") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.78, green: 0.12, blue: 0.17),
                end: Color(red: 0.56, green: 0.06, blue: 0.10),
                border: Color(red: 0.92, green: 0.45, blue: 0.49),
                icon: "rosette"
            )
        }

        if token == "npp" || token.contains("permit") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.10, green: 0.43, blue: 0.77),
                end: Color(red: 0.06, green: 0.27, blue: 0.54),
                border: Color(red: 0.43, green: 0.67, blue: 0.91),
                icon: "person.badge.plus"
            )
        }

        if token.contains("playoff") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.52, green: 0.11, blue: 0.64),
                end: Color(red: 0.32, green: 0.06, blue: 0.43),
                border: Color(red: 0.73, green: 0.40, blue: 0.82),
                icon: "trophy"
            )
        }

        if token.contains("x-bulls") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.16, green: 0.13, blue: 0.49),
                end: Color(red: 0.09, green: 0.07, blue: 0.31),
                border: Color(red: 0.46, green: 0.40, blue: 0.86),
                icon: "bolt.shield"
            )
        }

        if token.contains("x-broncs") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.82, green: 0.39, blue: 0.06),
                end: Color(red: 0.56, green: 0.22, blue: 0.03),
                border: Color(red: 0.95, green: 0.61, blue: 0.31),
                icon: "hare"
            )
        }

        if token.contains("legacy") || token.contains("steer roping") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.18, green: 0.44, blue: 0.18),
                end: Color(red: 0.10, green: 0.28, blue: 0.10),
                border: Color(red: 0.45, green: 0.72, blue: 0.45),
                icon: "lasso.badge.sparkles"
            )
        }

        let hue = hashHue(for: token)
        return TourBadgeStyle(
            foreground: Color.white,
            start: Color(hue: hue, saturation: 0.72, brightness: 0.70),
            end: Color(hue: hue, saturation: 0.82, brightness: 0.45),
            border: Color(hue: hue, saturation: 0.50, brightness: 0.90),
            icon: "flag"
        )
    }

    private func displayTourLabel(from source: String) -> String? {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed.lowercased()
        if normalized == "npp" || normalized == "cn" {
            return nil
        }

        return trimmed
    }

    private func hashHue(for token: String) -> Double {
        let sum = token.unicodeScalars.reduce(0) { partial, scalar in
            partial &+ Int(scalar.value)
        }
        return Double(sum % 360) / 360.0
    }
}

#Preview("PBJ Feed Card") {
    ZStack {
        Color.appBg.ignoresSafeArea()
        PBJFeedCard(
            item: PBJFeedItem(
                id: "preview-rodeo-1",
                title: "San Angelo Stock Show & Rodeo",
                subtitle: "PRCA ProRodeo with major weekend performances.",
                dateText: "Apr 10 - Apr 21",
                eventSortDate: nil,
                eventStartDate: nil,
                eventEndDate: nil,
                publishDate: nil,
                locationText: "San Angelo, TX",
                statusText: "Entries Open",
                eventsText: "BB, SW, SB, TR, BR",
                perfsText: "Perf 1-4",
                specialEntryFeesText: "BB-$70; SB-$70; BR-$70; TD-$175; SW-$175; TR-$175",
                addedMoneyText: "$430,000",
                addedMoneyTotal: 430000,
                entryWindowText: "Mar 29 - Apr 1",
                source: "PRCA",
                link: URL(string: "https://pbj.prorodeo.org"),
                detailFields: [
                    PBJDetailField(id: "rodeo_name", key: "rodeo_name", label: "Rodeo Name", value: "San Angelo Stock Show & Rodeo"),
                    PBJDetailField(id: "added_money", key: "added_money", label: "Added Money", value: "$430,000")
                ]
            )
        )
        .padding()
    }
}
