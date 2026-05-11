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
    
    let adPlacement: Int = 5
    
    //MARK: - Body
    var body: some View {
        let filteredRodeos = rodeos.sorted(by: { $0.endDate > $1.endDate })
        
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
                LazyVStack(spacing: AppSpace.lg) {
                    ForEach(filteredRodeos.indices, id: \.self) { index in
                        if (index % adPlacement) == 0 && index != 0 {
                            BannerAd(style: .mediumRectangle)
                        }
                        
                        NavigationLink {
                            SingleRodeoResults(
                                rodeoId: filteredRodeos[index].id,
                                rodeoName: filteredRodeos[index].name,
                                location: filteredRodeos[index].location,
                                endDate: filteredRodeos[index].endDate,
                                event: selectedEvent
                            )
                        } label: {
                            RodeoCell(rodeo: filteredRodeos[index])
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else if rodeos.count == 0 {
                ContentUnavailableView {
                    Label("No Results Found", systemImage: "list.number")
                        .foregroundColor(.appPrimary)
                }
            }
            
            LoadMoreButton(loading: loading, action: incrementIndex)
            
            BannerAd(style: .mediumRectangle)
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
        .animation(.easeOut(duration: 0.2), value: collapseProgress)
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
                Text("\(selectedEvent.title) Rodeo Results")
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

}

struct ResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
