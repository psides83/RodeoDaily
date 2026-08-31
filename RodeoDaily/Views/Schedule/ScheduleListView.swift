//
//  ScheduleListView.swift
//  RodeoDaily
//
//  Created by Codex on 2/19/26.
//

import SwiftUI

struct ScheduleListView: View {
    @Environment(\.colorScheme) private var colorScheme
    let rodeos: [RodeoData]
    let loading: Bool
    
    @Binding var index: Int
    @Binding var dateRange: Set<DateComponents>
    
    @State private var dateRangeDisplay = ""
    @State private var isShowingCalendar = false
    @State private var hasAttemptedLoad = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        let sortedRodeos = displayedRodeos
        let listRows = scheduleListRows(for: sortedRodeos)
        
        VStack(alignment: .leading, spacing: AppSpace.xxl) {
            listHeader
                .padding(.bottom, -20)
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 10)

            scheduleFilters
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 8)

            daysheetsResultsNote
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 8)
            
            if dateRange.count > 1 {
                FilterChip(dateRangeDisplay: dateRangeDisplay, dateRange: $dateRange)
                    .opacity(1 - collapseProgress)
                    .offset(y: -collapseProgress * 8)
            }
            
            if loading || (rodeos.isEmpty && !hasAttemptedLoad) {
                RodeosLoader()
            } else if !sortedRodeos.isEmpty {
                LazyVStack(spacing: AppSpace.lg) {
                    ForEach(listRows) { row in
                        switch row {
                        case .ad:
                            NativeAdCard(placement: .scheduleListInline)
                        case .rodeo(let rodeo):
                            NavigationLink {
                                RodeoScheduleDetailView(rodeo: rodeo)
                            } label: {
                                RodeoCell(rodeo: rodeo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Rodeos Found", systemImage: "calendar.badge.exclamationmark")
                        .foregroundColor(.appPrimary)
                } description: {
                    Text("There are no rodeos for this filter.")
                        .foregroundColor(.appPrimary)
                } actions: {
                    if dateRange.count > 1 {
                        Button {
                            withAnimation {
                                dateRange.removeAll()
                                dateRangeDisplay = ""
                            }
                        } label: {
                            Label("Clear Date Filter", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.loadingButton(false))
                    } else {
                        Button {
                            isShowingCalendar = true
                        } label: {
                            Label("Select Dates", systemImage: "calendar")
                        }
                        .buttonStyle(.loadingButton(false))
                    }
                }
            }
            
            LoadMoreButton(loading: loading, animateAction: false) {
                index += 1
            }
        }
        .padding(.bottom)
        .onChange(of: isShowingCalendar) { old, newValue in
            if !newValue && dateRange.count < 2 {
                dateRange.removeAll()
            }
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker(
                dateRange: $dateRange,
                dateRangeDisplay: $dateRangeDisplay,
                isShowingCalendar: $isShowingCalendar,
                allowsFutureDates: true
            )
        }
        .onAppear {
            if !rodeos.isEmpty {
                hasAttemptedLoad = true
            }
        }
        .onChange(of: loading) { _, isLoading in
            if !isLoading {
                hasAttemptedLoad = true
            }
        }
        .offset(coordinateSpcae: .named("HOME_TAB_SCROLL")) { value in
            scrollOffset = value
        }
        .overlay(alignment: .topLeading) {
            scheduleCollapsedStickyHeader
                .padding(.top, AppSpace.xs)
                .opacity(collapseProgress)
                .scaleEffect(0.96 + (0.04 * collapseProgress), anchor: .top)
                .offset(y: (1 - collapseProgress) * -14)
                .offset(y: -scrollOffset)
        }
    }
    
    var displayedRodeos: [RodeoData] {
        let filteredRodeos = dateRange.count > 1 ? rodeos : rodeos.filter { rodeo in
            guard let endDate = rodeo.endDate.rodeoDate else {
                return true
            }

            return rodeo.inProgress || endDate >= Calendar.current.startOfDay(for: Date.now)
        }

        return filteredRodeos.sorted { first, second in
            let firstDate = first.startDate.rodeoDate ?? first.endDate.rodeoDate ?? .distantFuture
            let secondDate = second.startDate.rodeoDate ?? second.endDate.rodeoDate ?? .distantFuture
            return firstDate < secondDate
        }
    }

    var listHeader: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text("Schedule")
                .foregroundColor(.appPrimary)
                .font(.appSectionTitle)
                .fontWeight(.bold)

            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text("Upcoming Rodeos")
                    .foregroundColor(.appSecondary)
                    .font(.appCardTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)

                Spacer()
            }
        }
        .appCardStyle()
    }

    var scheduleFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Button {
                isShowingCalendar = true
            } label: {
                chipContent(
                    title: NSLocalizedString("Dates", comment: ""),
                    value: dateRange.count > 1 ? dateRangeDisplay.replacingOccurrences(of: "Current Range: ", with: "") : "Select Range",
                    trailingSystemImage: "calendar"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var daysheetsResultsNote: some View {
        HStack(alignment: .top, spacing: AppSpace.sm) {
            Image(systemName: "info.circle")
                .font(.appCaptionStrong)
                .foregroundColor(.appSecondary)

            Text(NSLocalizedString("Day sheets for \"In Progress\" rodeos can be viewed in Rodeo Results.", comment: ""))
                .font(.appCaption)
                .foregroundColor(.appTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppSpace.xs)
    }

    private var scheduleCollapsedStickyHeader: some View {
        VStack(alignment: .center, spacing: AppSpace.xxs) {
            Text("Schedule")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)

            if dateRange.count > 1 {
                Text(dateRangeDisplay.replacingOccurrences(of: "Current Range: ", with: ""))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .opacity(0.85)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, AppSpace.lg)
        .padding(.vertical, AppSpace.xs)
        .padding(.horizontal, AppSpace.sm)
        .background {
            Capsule(style: .continuous)
                .stroke(.gray.opacity(0.25), lineWidth: 1.5)
                .background(
                    Capsule(style: .continuous)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.42) : Color.appBg.opacity(0.8))
                )
                .background(
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .compositingGroup()
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

    private var collapseProgress: CGFloat {
        let y = -scrollOffset
        let start: CGFloat = 30
        let distance: CGFloat = 70
        let progress = (y - start) / distance
        return min(max(progress, 0), 1)
    }

    private func scheduleListRows(for rodeos: [RodeoData]) -> [ScheduleListRow] {
        var rows: [ScheduleListRow] = []
        var adSlot = 0

        for (listIndex, rodeo) in rodeos.enumerated() {
            if shouldShowScheduleAd(beforeItemAt: listIndex, adSlot: adSlot) {
                rows.append(.ad(adSlot))
                adSlot += 1
            }

            rows.append(.rodeo(rodeo))
        }

        return rows
    }

    private func shouldShowScheduleAd(beforeItemAt index: Int, adSlot: Int) -> Bool {
        guard adSlot < 2 else { return false }
        return AdPlacementPolicy.shouldShowListAd(beforeItemAt: index, firstAfter: 8, repeatEvery: 20)
    }

    private enum ScheduleListRow: Identifiable {
        case rodeo(RodeoData)
        case ad(Int)

        var id: String {
            switch self {
            case .rodeo(let rodeo):
                return "rodeo-\(rodeo.id)"
            case .ad(let slot):
                return "schedule-ad-\(slot)"
            }
        }
    }
}

#Preview {
    ContentView()
}
