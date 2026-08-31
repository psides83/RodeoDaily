//
//  HomeView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/16/22.
//

import SwiftUI

fileprivate enum HomeTabItem: String, CaseIterable {
    case standings = "Standings"
    case results = "Results"
    case schedule = "Schedule"
    case more = "More"

    var symbol: String {
        switch self {
        case .standings: return "list.number"
        case .results: return "dollarsign.square"
        case .schedule: return "calendar"
        case .more: return "ellipsis.circle"
        }
    }

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }

    var tab: Tabs {
        switch self {
        case .standings: return .standings
        case .results: return .results
        case .schedule: return .schedule
        case .more: return .more
        }
    }

    static func from(tab: Tabs) -> HomeTabItem {
        switch tab {
        case .standings: return .standings
        case .results: return .results
        case .schedule: return .schedule
        case .more: return .more
        }
    }
}

fileprivate struct HomeCustomTabBar: View {
    @Environment(\.colorScheme) private var colorScheme

    var showsSearchBar: Bool = false
    @Binding var activeTab: HomeTabItem
    @Binding var searchText: String
    var onSearchBarExpanded: (Bool) -> ()
    var onSearchTextFieldActive: (Bool) -> ()
    var onSearchSubmit: () -> ()
    /// View Properties
    @GestureState private var isActive: Bool = false
    @State private var isInitialOffsetSet: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragOffset: CGFloat?
    /// Search Bar Properties
    @State private var isSearchExpanded: Bool = false
    @FocusState private var isKeyboardActive: Bool

    var body: some View {
        GeometryReader {
            let size = $0.size
            let tabs = HomeTabItem.allCases.prefix(showsSearchBar ? 4 : 5)
            let tabItemWidth = max(min(size.width / CGFloat(tabs.count + (showsSearchBar ? 1 : 0)), 90), 60)
            let tabItemHeight: CGFloat = 56

            ZStack {
                if isInitialOffsetSet {
                    let mainLayout = isKeyboardActive ? AnyLayout(ZStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(spacing: 12))

                    mainLayout {
                        let tabLayout = isSearchExpanded ? AnyLayout(ZStackLayout()) : AnyLayout(HStackLayout(spacing: 0))

                        tabLayout {
                            ForEach(tabs, id: \.rawValue) { tab in
                                TabItemView(
                                    tab,
                                    width: isSearchExpanded ? 45 : tabItemWidth,
                                    height: isSearchExpanded ? 45 : tabItemHeight
                                )
                                .opacity(isSearchExpanded ? (activeTab == tab ? 1 : 0) : 1)
                            }
                        }
                        .background(alignment: .leading) {
                            ZStack {
                                Capsule(style: .continuous)
                                    .stroke(.gray.opacity(0.25), lineWidth: 3)
                                    .opacity(isActive ? 1 : 0)

                                Capsule(style: .continuous)
                                    .fill(.background)
                            }
                            .compositingGroup()
                            .frame(width: tabItemWidth, height: tabItemHeight)
                            .scaleEffect(isActive ? 1.3 : 1)
                            .offset(x: isSearchExpanded ? 0 : dragOffset)
                            .opacity(isSearchExpanded ? 0 : 1)
                        }
                        .padding(3)
                        .background(TabBarBackground())
                        .overlay {
                            if isSearchExpanded {
                                Capsule()
                                    .foregroundStyle(.clear)
                                    .contentShape(.capsule)
                                    .onTapGesture {
                                        withAnimation(.bouncy) {
                                            isSearchExpanded = false
                                        }
                                    }
                            }
                        }
                        .opacity(isKeyboardActive ? 0 : 1)

                        if showsSearchBar {
                            ExpandableSearchBar(height: isSearchExpanded ? 45 : tabItemHeight)
                        }
                    }
                    .optionalGeometryGroup()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                guard !isInitialOffsetSet else { return }
                dragOffset = CGFloat(activeTab.index) * tabItemWidth
                isInitialOffsetSet = true
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 25)
        .padding(.bottom, isKeyboardActive ? 10 : 0)
        .animation(.bouncy, value: dragOffset)
        .animation(.bouncy, value: isActive)
        .animation(.smooth, value: activeTab)
        .animation(.easeInOut(duration: 0.25), value: isKeyboardActive)
        .customOnChange(value: isKeyboardActive) {
            onSearchTextFieldActive($0)
        }
        .customOnChange(value: isSearchExpanded) {
            onSearchBarExpanded($0)
        }
    }

    @ViewBuilder
    private func TabItemView(_ tab: HomeTabItem, width: CGFloat, height: CGFloat) -> some View {
        let tabs = HomeTabItem.allCases.prefix(showsSearchBar ? 4 : 5)
        let tabCount = tabs.count - 1

        VStack(spacing: 6) {
            Image(systemName: tab.symbol)
                .font(.title2)
                .symbolVariant(.fill)

            if !isSearchExpanded {
                Text(NSLocalizedString(tab.rawValue, comment: ""))
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(activeTab == tab && !isSearchExpanded ? accentColor : inactiveColor)
        .frame(width: width, height: height)
        .contentShape(.capsule)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isActive, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    let xOffset = value.translation.width
                    if let lastDragOffset {
                        let newDragOffset = xOffset + lastDragOffset
                        dragOffset = max(min(newDragOffset, CGFloat(tabCount) * width), 0)
                    } else {
                        lastDragOffset = dragOffset
                    }
                })
                .onEnded({ _ in
                    lastDragOffset = nil
                    let landingIndex = Int((dragOffset / width).rounded())
                    if tabs.indices.contains(landingIndex) {
                        dragOffset = CGFloat(landingIndex) * width
                        activeTab = tabs[landingIndex]
                    }
                })
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    activeTab = tab
                    dragOffset = CGFloat(tab.index) * width
                }
        )
        .optionalGeometryGroup()
    }

    @ViewBuilder
    private func TabBarBackground() -> some View {
        ZStack {
            Capsule(style: .continuous)
                .stroke(.gray.opacity(0.25), lineWidth: 1.5)

            Capsule(style: .continuous)
                .fill(.background.opacity(0.8))

            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .compositingGroup()
    }

    @ViewBuilder
    private func ExpandableSearchBar(height: CGFloat) -> some View {
        let searchLayout = isKeyboardActive ? AnyLayout(HStackLayout(spacing: 12)) : AnyLayout(ZStackLayout(alignment: .trailing))

        searchLayout {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(isSearchExpanded ? .body : .title2)
                    .foregroundStyle(isSearchExpanded ? .gray : inactiveColor)
                    .frame(width: isSearchExpanded ? nil : height, height: height)
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            isSearchExpanded = true
                        }
                    }
                    .allowsHitTesting(!isSearchExpanded)

                if isSearchExpanded {
                    TextField("Search...", text: $searchText)
                        .focused($isKeyboardActive)
                        .submitLabel(.search)
                        .onSubmit(onSearchSubmit)
                }
            }
            .padding(.horizontal, isSearchExpanded ? 15 : 0)
            .background(TabBarBackground())
            .optionalGeometryGroup()
            .zIndex(1)

            Button {
                searchText = ""
                isKeyboardActive = false
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(inactiveColor)
                    .frame(width: height, height: height)
                    .background(TabBarBackground())
            }
            .opacity(isKeyboardActive ? 1 : 0)
        }
    }

    var accentColor: Color {
        .rdYellow
    }

    var inactiveColor: Color {
        colorScheme == .dark ? .white : .rdGreen
    }
}

extension HomeView {
    private var hideThreshold: CGFloat { 14 }
    private var showThreshold: CGFloat { 8 }

    private var activeCustomTab: Binding<HomeTabItem> {
        Binding(
            get: { HomeTabItem.from(tab: selectedTab) },
            set: { selectedTab = $0.tab }
        )
    }

    private func trackScrollOffset(_ value: CGFloat) {
        guard !isTabBarSearchActive else { return }

        let delta = value - lastTrackedScrollOffset
        lastTrackedScrollOffset = value
        homeHeaderScrollOffset = max(0, value)

        if delta > hideThreshold, !tabBarHidden {
            withAnimation(.easeInOut(duration: 0.32)) {
                tabBarHidden = true
            }
        } else if delta < -showThreshold, tabBarHidden {
            withAnimation(.easeInOut(duration: 0.32)) {
                tabBarHidden = false
            }
        }
    }

    private func submitTabSearch() async {
        switch selectedTab {
        case .results:
            await rodeosApi.searchRodeos(for: resultsEvent, by: search.text, in: dateParams) {
                rodeosApi.endLoading()
            }
        case .schedule:
            await scheduleApi.searchRodeos(for: .bb, by: search.text, in: dateParams) {
                scheduleApi.endLoading()
            }
        default:
            break
        }
    }

    @ViewBuilder
    private var currentTabContent: some View {
        switch selectedTab {
        case .standings:
            ScrollView(.vertical, showsIndicators: false) {
                StandingsList(
                    widgetAthletes: widgetAthletes,
                    followedAthletes: followedAthletes,
                    standings: standingsApi.standings,
                    loading: standingsApi.loading,
                    selectedTab: selectedTab,
                    searchText: search.text,
                    selectedYear: $selectedYear,
                    selectedEvent: $standingsEvent,
                    standingType: $standingType,
                    selectedCircuit: $circuit
                )
                .padding()
                .padding(.bottom, 86)
                .offset(coordinateSpcae: .named("HOME_TAB_SCROLL")) { value in
                    trackScrollOffset(-value)
                }
            }
            .coordinateSpace(name: "HOME_TAB_SCROLL")
            .refreshable {
                await refreshCurrentTab(.standings)
            }

        case .results:
            ScrollView(.vertical, showsIndicators: false) {
                ResultsList(
                    rodeos: rodeosApi.rodeos,
                    loading: rodeosApi.loading,
                    widgetAthletes: widgetAthletes,
                    selectedEvent: $resultsEvent,
                    index: $index,
                    dateRange: $dateRange
                )
                .padding()
                .padding(.bottom, 86)
                .offset(coordinateSpcae: .named("HOME_TAB_SCROLL")) { value in
                    trackScrollOffset(-value)
                }
            }
            .coordinateSpace(name: "HOME_TAB_SCROLL")
            .refreshable {
                await refreshCurrentTab(.results)
            }

        case .schedule:
            ScrollView(.vertical, showsIndicators: false) {
                ScheduleListView(
                    rodeos: scheduleApi.rodeos,
                    loading: scheduleApi.loading,
                    index: $index,
                    dateRange: $dateRange
                )
                .padding()
                .padding(.bottom, 86)
                .offset(coordinateSpcae: .named("HOME_TAB_SCROLL")) { value in
                    trackScrollOffset(-value)
                }
            }
            .coordinateSpace(name: "HOME_TAB_SCROLL")
            .refreshable {
                await refreshCurrentTab(.schedule)
            }

        case .more:
            ScrollView(.vertical, showsIndicators: false) {
                MoreView()
                    .padding()
                    .padding(.bottom, 86)
                    .offset(coordinateSpcae: .named("HOME_TAB_SCROLL")) { value in
                        trackScrollOffset(-value)
                    }
            }
            .coordinateSpace(name: "HOME_TAB_SCROLL")
        }
    }

    //MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            currentTabContent
                .background(Color.appBg)

            VStack(spacing: 0) {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.30), location: 0.0),
                        .init(color: .black.opacity(0.16), location: 0.42),
                        .init(color: .black.opacity(0.0), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 130)
                .ignoresSafeArea(edges: .top)
                Spacer(minLength: 0)
            }
            .opacity(tabBarHidden ? 0 : 1)
            .allowsHitTesting(false)

            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.0), location: 0.0),
                    .init(color: .black.opacity(0.06), location: 0.35),
                    .init(color: .black.opacity(0.14), location: 0.68),
                    .init(color: .black.opacity(0.22), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, alignment: .bottom)
            .frame(height: 320, alignment: .bottom)
            .offset(y: 80)
            .ignoresSafeArea(edges: .bottom)
            .opacity(tabBarHidden ? 0 : 1)
            .allowsHitTesting(false)

            if let refreshFeedbackMessage {
                refreshFeedbackBanner(refreshFeedbackMessage)
                    .padding(.horizontal, AppSpace.lg)
                    .padding(.bottom, tabBarHidden ? 28 : 104)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
            }

            HomeCustomTabBar(
                showsSearchBar: true,
                activeTab: activeCustomTab,
                searchText: $search.text
            ) { expanded in
                isTabBarSearchActive = expanded
                if expanded {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        tabBarHidden = false
                    }
                }
            } onSearchTextFieldActive: { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    tabBarHidden = false
                }
            } onSearchSubmit: {
                Task {
                    await submitTabSearch()
                }
            }
            .padding(.bottom, 10)
            .offset(y: tabBarHidden ? 120 : 0)
            .opacity(tabBarHidden ? 0.0 : 1.0)
            .allowsHitTesting(!tabBarHidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            refreshFeedbackTask?.cancel()
        }
        .onAppear {
            if initialLoad {
                standingsEvent = favoriteStandingsEvent.normalizedForStandingsFilter
                resultsEvent = favoriteResultsEvent
                initialLoad = false
            }
            if !didTrackInitialTabView {
                AnalyticsService.shared.track(.tabViewed(name: selectedTab.analyticsName))
                didTrackInitialTabView = true
            }
            tabBarHidden = false
            lastTrackedScrollOffset = 0
            
            Task {
                await standingsApi.getStandings(
                    for: standingsEvent,
                    type: standingType,
                    circuit: circuit,
                    selectedYear: selectedYear
                )
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            tabBarHidden = false
            lastTrackedScrollOffset = 0
            AnalyticsService.shared.track(.tabViewed(name: newValue.analyticsName))
            
            Task {
                if newValue == .standings {
                    clearSearch()
                    await standingsApi.getStandings(
                        for: standingsEvent,
                        type: standingType,
                        circuit: circuit,
                        selectedYear: selectedYear
                    )
                }

                if newValue == .more {
                    clearSearch()
                }
                
                if newValue == .results {
                    clearSearch()
                    await rodeosApi.loadRodeos(
                        event: resultsEvent,
                        index: index,
                        searchText: "",
                        dateParams: dateParams
                    ) { rodeosApi.endLoading() }
                }

                if newValue == .schedule {
                    clearSearch()
                    dateRange.removeAll()
                    index = 1
                    await scheduleApi.loadRodeos(
                        event: .bb,
                        index: 1,
                        searchText: "",
                        dateParams: ""
                    ) { scheduleApi.endLoading() }
                }
            }
        }
        .onChange(of: widgetStandingsEvent) { _, event in
            guard let event else { return }
            let normalizedEvent = event.normalizedForStandingsFilter

            if selectedTab != .standings {
                standingsEvent = normalizedEvent
                selectedTab = .standings
            } else {
                standingsEvent = normalizedEvent
            }

            widgetStandingsEvent = nil
        }
//        .task(id: selectedTab) {
//            switch selectedTab {
//            case .standings:
//                await standingsApi.getStandings(
//                    for: standingsEvent,
//                    type: standingType,
//                    selectedYear: selectedYear,
//                    circuit: circuit
//                )
//            case .results:
//                await rodeosApi.loadRodeos(
//                    event: resultsEvent,
//                    index: index,
//                    searchText: "",
//                    dateParams: dateParams
//                ) {
//                    rodeosApi.endLoading()
//                }
//            default:
//                break
//            }
//        }
        .onChange(of: standingsEvent) { _, newValue in
            let normalizedEvent = newValue.normalizedForStandingsFilter
            if normalizedEvent != newValue {
                standingsEvent = normalizedEvent
                return
            }

            guard selectedTab == .standings else { return }
            trackStandingsFilterChange(event: newValue, type: standingType, circuit: circuit, year: selectedYear)
            Task {
                await standingsApi.getStandings(
                    for: newValue,
                    type: standingType,
                    circuit: circuit,
                    selectedYear: selectedYear
                )
            }
        }
        .onChange(of: standingType) { _, newValue in
            guard selectedTab == .standings else { return }
            trackStandingsFilterChange(event: standingsEvent, type: newValue, circuit: circuit, year: selectedYear)
            Task {
                await standingsApi.getStandings(
                    for: standingsEvent,
                    type: newValue,
                    circuit: circuit,
                    selectedYear: selectedYear
                )
            }
        }
        .onChange(of: circuit) { _, newValue in
            guard selectedTab == .standings else { return }
            trackStandingsFilterChange(event: standingsEvent, type: standingType, circuit: newValue, year: selectedYear)
            Task {
                await standingsApi.getStandings(
                    for: standingsEvent,
                    type: standingType,
                    circuit: newValue,
                    selectedYear: selectedYear
                )
            }
        }
        .onChange(of: selectedYear) { _, newValue in
            guard selectedTab == .standings else { return }
            trackStandingsFilterChange(event: standingsEvent, type: standingType, circuit: circuit, year: newValue)
            Task {
                await standingsApi.getStandings(
                    for: standingsEvent,
                    type: standingType,
                    circuit: circuit,
                    selectedYear: newValue
                )
            }
        }
        .onChange(of: resultsEvent) {
            guard selectedTab == .results else { return }
            AnalyticsService.shared.track(.resultsFilterChanged(event: resultsEvent.rawValue, hasDateRange: !dateParams.isEmpty))
            Task {
                await rodeosApi.loadRodeos(
                    event: resultsEvent,
                    index: index,
                    searchText: search.text,
                    dateParams: dateParams
                ) { rodeosApi.endLoading() }
            }
        }
        .onChange(of: index) { _, newValue in
            guard selectedTab == .results || selectedTab == .schedule else { return }
            Task {
                if selectedTab == .results {
                    await rodeosApi.loadRodeos(
                        event: resultsEvent,
                        index: newValue,
                        searchText: search.text,
                        dateParams: dateParams
                    ) { rodeosApi.endLoading() }
                } else {
                    await scheduleApi.loadRodeos(
                        event: .bb,
                        index: newValue,
                        searchText: search.text,
                        dateParams: dateParams
                    ) { scheduleApi.endLoading() }
                }
            }
        }
        .onChange(of: dateRange) { _, newValue in
            guard selectedTab == .results || selectedTab == .schedule else { return }
            if index != 1 {
                index = 1
            }
            Task {
                if selectedTab == .results {
                    AnalyticsService.shared.track(.resultsFilterChanged(event: resultsEvent.rawValue, hasDateRange: !newValue.isEmpty))
                    if !dateParams.isEmpty {
                        await rodeosApi.loadRodeos(
                            for: resultsEvent,
                            in: dateParams,
                            with: search.text
                        ) { rodeosApi.endLoading() }
                    }

                    if newValue.isEmpty {
                        await rodeosApi.loadRodeos(
                            event: resultsEvent,
                            index: 1,
                            searchText: search.text,
                            dateParams: dateParams
                        ) { rodeosApi.endLoading() }
                    }
                } else {
                    AnalyticsService.shared.track(.scheduleFilterChanged(hasDateRange: !newValue.isEmpty))
                    if !dateParams.isEmpty {
                        await scheduleApi.loadRodeos(
                            for: .bb,
                            in: dateParams,
                            with: search.text
                        ) { scheduleApi.endLoading() }
                    }

                    if newValue.isEmpty {
                        await scheduleApi.loadRodeos(
                            event: .bb,
                            index: 1,
                            searchText: search.text,
                            dateParams: dateParams
                        ) { scheduleApi.endLoading() }
                    }
                }
            }
        }
        .onChange(of: search.text) { _, newValue in
            guard selectedTab == .results || selectedTab == .schedule else { return }
            guard newValue.isEmpty else { return }
            Task {
                if selectedTab == .results {
                    await rodeosApi.loadRodeos(
                        event: resultsEvent,
                        index: 1,
                        searchText: "",
                        dateParams: dateParams
                    ) { rodeosApi.endLoading() }
                } else {
                    await scheduleApi.loadRodeos(
                        event: .bb,
                        index: 1,
                        searchText: "",
                        dateParams: dateParams
                    ) { scheduleApi.endLoading() }
                }
            }
        }
    }

    private func trackStandingsFilterChange(event: StandingsEvent, type: StandingType, circuit: Circuit, year: String) {
        AnalyticsService.shared.track(
            .standingsFilterChanged(
                event: event.rawValue,
                type: type.rawValue,
                circuit: circuit.title,
                year: year
            )
        )
    }

    @ViewBuilder
    private func refreshFeedbackBanner(_ message: String) -> some View {
        HStack(spacing: AppSpace.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.appCaptionStrong)
                .foregroundColor(.appSecondary)

            Text(message)
                .font(.appCaptionStrong)
                .foregroundColor(.appPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, AppSpace.md)
        .padding(.vertical, AppSpace.sm)
        .background(
            Capsule(style: .continuous)
                .fill(homeColorScheme == .dark ? Color.black.opacity(0.82) : Color.appBg.opacity(0.96))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
        )
        .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)
    }

    private func refreshCurrentTab(_ tab: Tabs) async {
        switch tab {
        case .standings:
            await standingsApi.getStandings(
                for: standingsEvent,
                type: standingType,
                circuit: circuit,
                selectedYear: selectedYear
            )
            showRefreshFeedback(NSLocalizedString("Standings refreshed", comment: ""))
        case .results:
            await rodeosApi.loadRodeos(
                event: resultsEvent,
                index: 1,
                searchText: search.text,
                dateParams: dateParams
            ) { rodeosApi.endLoading() }
            showRefreshFeedback(NSLocalizedString("Results refreshed", comment: ""))
        case .schedule:
            await scheduleApi.loadRodeos(
                event: .bb,
                index: 1,
                searchText: search.text,
                dateParams: dateParams
            ) { scheduleApi.endLoading() }
            showRefreshFeedback(NSLocalizedString("Schedule refreshed", comment: ""))
        case .more:
            break
        }
    }

    private func showRefreshFeedback(_ message: String) {
        refreshFeedbackTask?.cancel()

        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            refreshFeedbackMessage = message
        }

        refreshFeedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.22)) {
                    refreshFeedbackMessage = nil
                }
            }
        }
    }

}

extension View {
    @ViewBuilder
    func optionalGeometryGroup() -> some View {
        if #available(iOS 17, *) {
            self
                .geometryGroup()
        } else {
            self
        }
    }

    @ViewBuilder
    func customOnChange<T: Equatable>(value: T, result: @escaping (T) -> ()) -> some View {
        if #available(iOS 17, *) {
            self
                .onChange(of: value) { _, newValue in
                    result(newValue)
                }
        } else {
            self
                .onChange(of: value) { newValue in
                    result(newValue)
                }
        }
    }
}
