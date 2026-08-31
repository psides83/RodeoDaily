//
//  LayoutAlt.swift
//  RodeoDaily
//
//  Created by Payton Sides on 11/8/25.
//

import SwiftData
import SwiftUI

struct LayoutAltView: View {
    @Environment(\.calendar) var calendar
        
     let coordinateSpace = "SCROLL"
    
    @StateObject var standingsApi = StandingsApi()
    @StateObject var rodeosApi = RodeosApi()
    
    @Query(sort: \WidgetAthlete.sortOrder) var widgetAthletes: [WidgetAthlete]
    
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
    @AppStorage("favoriteResultsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteResultsEvent: Events.CodingKeys = .bb
    
    // MARK: - State Properties
    @FocusState var searchFieldFocused: Bool
    
    @StateObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.5)
    
    @State var standingsEvent: StandingsEvent = .aa
    @State var resultsEvent: Events.CodingKeys = .bb
    @State var initialLoad = true
    @State var selectedTab: Tabs = .standings
    @State var offSetY: CGFloat = 0
    @State var isShowingSearchBar = false
    @State var selectedYear = Date().yearString
    @State var standingType: StandingType = .world
    @State var circuit: Circuit = .columbiaRiver
    @State var index = 1
    @State var dateRange = Set<DateComponents>()
    @State var navigatedToSettings = false
    @State var searchText = ""
    
    // MARK: - Computed Properties
    var dateParams: String {
        var range = dateRange.compactMap { components in
            calendar.date(from: components)
        }.sorted(by: { $0 < $1 })
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/d/yyyy"
        
        if range.count > 1 {
            guard let first = range.first else { return "" }
            guard let last = range.last else { return "" }
            
            range.forEach { date in
                let index = range.firstIndex(of: date)
                range.remove(at: index!)
            }
            
            let firstDate = formatter.string(from: first).replacingOccurrences(of: "/", with: "%2F")
            
            
            let secondDate = formatter.string(from: last).replacingOccurrences(of: "/", with: "%2F")
            
            return "&start=\(firstDate)&end=\(secondDate)"
        }
        
        return ""
    }
    
    var navTitle: String {
        "\(standingsEvent.displayWithTeamRopingConversion) \(selectedYear)"
    }
    
    // MARK: - Methods
    func clearSearch() {
        search.text = ""
        index = 1
        searchFieldFocused = false
    }
    var body: some View {
        TabView {
            NavigationStack {
//                ScrollView {
                
                StandingsListProt(
                        widgetAthletes: widgetAthletes,
                        standings: standingsApi.standings,
                        loading: standingsApi.loading,
                        selectedTab: selectedTab,
                        searchText: searchText,
                        selectedYear: $selectedYear,
                        selectedEvent: $standingsEvent,
                        standingType: $standingType,
                        selectedCircuit: $circuit
                )
                .searchable(text: $searchText, placement: .automatic)
//                }
                .navigationTitle(navTitle)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .onChange(of: standingsEvent) { old, newValue in
                Task {
                    await standingsApi.getStandings(
                        for: newValue,
                        type: standingType,
                        circuit: circuit,
                        selectedYear: selectedYear
                    )
                }
            }
            .onChange(of: standingType) { old, newValue in
                Task {
                    await standingsApi.getStandings(
                        for: standingsEvent,
                        type: newValue,
                        circuit: circuit,
                        selectedYear: selectedYear
                    )
                }
            }
            .onChange(of: circuit) { old, newValue in
                Task {
                    await standingsApi.getStandings(
                        for: standingsEvent,
                        type: standingType,
                        circuit: newValue,
                        selectedYear: selectedYear
                    )
                }
            }
            .onAppear {
                if initialLoad {
                    standingsEvent = favoriteStandingsEvent
                    resultsEvent = favoriteResultsEvent
                }
            }
            .task {
                if initialLoad {
                    if selectedTab == .standings {
                        await standingsApi.getStandings(for: standingsEvent, selectedYear: selectedYear)
                        initialLoad = false
                    }
                    
                    if selectedTab == .results {
                        await rodeosApi.loadRodeos(
                            event: resultsEvent,
                            index: index,
                            searchText: "",
                            dateParams: dateParams
                        ) {
                            initialLoad = false
                        }
                    }
                }
            }

//                    SearchView()
//                        .tabItem {
//                            Label("Search", systemImage: "magnifyingglass")
//                        }

//                    ProfileView()
//                        .tabItem {
//                            Label("Profile", systemImage: "person.fill")
//                        }
                }
//                .tint(.blue) // Optional: changes the accent color of the selected tab
    }
}

#Preview {
    LayoutAltView()
}
