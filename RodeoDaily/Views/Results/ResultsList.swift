//
//  ResultsList.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct ResultsList: View {        
    @Environment(\.colorScheme) private var colorScheme
    let rodeos: [RodeoData]
    let loading: Bool
    var widgetAthletes: [WidgetAthlete]
    
    @Binding var selectedEvent: Events.CodingKeys
    @Binding var index: Int
    @Binding var dateRange: Set<DateComponents>
    
    @State var dateRangeDisplay = ""
    @State var isShowingCalendar = false
    @State private var hasAttemptedLoad = false
    @State private var scrollOffset: CGFloat = 0
    
    //MARK: - Body
    var body: some View {
        let filteredRodeos = rodeos.sorted(by: { $0.endDate > $1.endDate })
        let inProgressRodeos = filteredRodeos.filter(\.inProgress)
        let completedRodeos = filteredRodeos.filter { !$0.inProgress }
        let completedRows = resultsListRows(for: completedRodeos)
        
        VStack(alignment: .leading, spacing: AppSpace.xxl) {
            resultsHeader
                .padding(.bottom, -20)
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 10)
            resultsFilters
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 10)
            
            if dateRange.count > 1 {
                FilterChip(dateRangeDisplay: dateRangeDisplay, dateRange: $dateRange)
                    .opacity(1 - collapseProgress)
                    .offset(y: -collapseProgress * 8)
            }
            
            if loading || (rodeos.isEmpty && !hasAttemptedLoad) {
                RodeosLoader()
            } else if rodeos.count > 0 {
                LazyVStack(alignment: .leading, spacing: AppSpace.lg) {
                    if !inProgressRodeos.isEmpty {
                        resultsSectionHeader(
                            title: NSLocalizedString("In Progress", comment: "")
                        )

                        ForEach(inProgressRodeos) { rodeo in
                            resultsRodeoLink(rodeo)
                        }
                    }

                    if !completedRodeos.isEmpty {
                        resultsSectionHeader(
                            title: NSLocalizedString("Completed Rodeos", comment: "")
                        )

                        ForEach(completedRows) { row in
                            switch row {
                            case .ad:
                                NativeAdCard(placement: .resultsListInline)
                            case .rodeo(let rodeo):
                                resultsRodeoLink(rodeo)
                            }
                        }
                    }
                }
            } else if rodeos.count == 0 {
                noResultsView
            }
            
            LoadMoreButton(loading: loading, animateAction: false, action: incrementIndex)
        }
        .padding(.bottom)
        .onChange(of: isShowingCalendar) { old, newValue in
            if newValue == false && dateRange.count < 2 {
                dateRange.removeAll()
            }
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
            resultsCollapsedStickyHeader
                .padding(.top, AppSpace.xs)
                .opacity(collapseProgress)
                .scaleEffect(0.96 + (0.04 * collapseProgress), anchor: .top)
                .offset(y: (1 - collapseProgress) * -14)
            .offset(y: -scrollOffset)
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker(dateRange: $dateRange, dateRangeDisplay: $dateRangeDisplay, isShowingCalendar: $isShowingCalendar)
        }
    }
    
    // MARK: - Sub Views
    var resultsHeader: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text("Results")
                .foregroundColor(.appPrimary)
                .font(.appSectionTitle)
                .fontWeight(.bold)
            
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text(String(format: NSLocalizedString("%@ Rodeo Results", comment: ""), selectedEvent.title))
                    .foregroundColor(.appSecondary)
                    .font(.appCardTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Spacer()
            }
        }
        .appCardStyle()
    }
    
    var resultsFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace.sm) {
                filterMenuChip(
                    title: NSLocalizedString("Event", comment: ""),
                    value: selectedEvent.title
                ) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Button(event.title) {
                            withAnimation {
                                selectedEvent = event
                            }
                        }
                    }
                }
                
                Button {
                    showCalendar()
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
    }

    private var resultsCollapsedStickyHeader: some View {
        VStack(alignment: .center, spacing: AppSpace.xxs) {
            Text(selectedEvent.title)
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

    private func resultsSectionHeader(title: String) -> some View {
        HStack(spacing: AppSpace.xs) {
            Text(title)
                .font(.appCardTitle)
                .foregroundColor(.appPrimary)
                .fontWeight(.bold)
        }
        .padding(.horizontal, AppSpace.xs)
    }

    private func resultsRodeoLink(_ rodeo: RodeoData) -> some View {
        NavigationLink {
            SingleRodeoResults(
                rodeoId: rodeo.id,
                rodeoName: rodeo.name,
                location: rodeo.location,
                endDate: rodeo.endDate,
                event: selectedEvent,
                hasDaysheets: rodeo.hasDaysheets
            )
            .onAppear {
                AnalyticsService.shared.track(
                    .rodeoDetailViewed(source: "results", rodeoID: rodeo.id)
                )
            }
        } label: {
            RodeoCell(rodeo: rodeo)
        }
        .buttonStyle(.plain)
    }

    private var noResultsView: some View {
        ContentUnavailableView {
            Label("No Results Found", systemImage: "list.number")
                .foregroundColor(.appPrimary)
        } description: {
            Text("There are no results for this filter.")
                .foregroundColor(.appPrimary)
        } actions: {
            VStack(spacing: AppSpace.sm) {
                Menu {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Button(event.title) {
                            withAnimation {
                                selectedEvent = event
                            }
                        }
                    }
                } label: {
                    Label("Change Event", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.loadingButton(false))

                if dateRange.count > 1 {
                    Button {
                        withAnimation {
                            dateRange.removeAll()
                            dateRangeDisplay = ""
                        }
                    } label: {
                        Label("Clear Date Filter", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.clearTextButton)
                }
            }
        }
    }
    
    // MARK: - Methods
    func showCalendar() {
        isShowingCalendar = true
    }
    
    func incrementIndex() {
        index += 1
    }

    private var collapseProgress: CGFloat {
        let y = -scrollOffset
        let start: CGFloat = 30
        let distance: CGFloat = 70
        let progress = (y - start) / distance
        return min(max(progress, 0), 1)
    }

    private func resultsListRows(for rodeos: [RodeoData]) -> [ResultsListRow] {
        var rows: [ResultsListRow] = []
        var adSlot = 0

        for (listIndex, rodeo) in rodeos.enumerated() {
            if shouldShowResultsAd(beforeItemAt: listIndex, adSlot: adSlot) {
                rows.append(.ad(adSlot))
                adSlot += 1
            }

            rows.append(.rodeo(rodeo))
        }

        return rows
    }

    private func shouldShowResultsAd(beforeItemAt index: Int, adSlot: Int) -> Bool {
        guard adSlot < 2 else { return false }
        return AdPlacementPolicy.shouldShowListAd(beforeItemAt: index, firstAfter: 8, repeatEvery: 20)
    }

    private enum ResultsListRow: Identifiable {
        case rodeo(RodeoData)
        case ad(Int)

        var id: String {
            switch self {
            case .rodeo(let rodeo):
                return "rodeo-\(rodeo.id)"
            case .ad(let slot):
                return "results-ad-\(slot)"
            }
        }
    }

}

struct ResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
