//
//  HomeView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import SwiftData
import SwiftUI

// MARK: - View Model
/// Funcitons as the view model for the Home view with the header view.
/// The view sections are housed in sseperate files and only house View code.
struct HomeView: View {
    @Environment(\.calendar) var calendar
        
     let coordinateSpace = "SCROLL"
    
    @StateObject var standingsApi = StandingsApi()
    @StateObject var rodeosApi = RodeosApi()
    @StateObject var scheduleApi = RodeoScheduleApi()
    @StateObject var pbjApi = PBJFeedApi()
    
    @Query var widgetAthletes: [WidgetAthlete]
    @Query var followedAthletes: [FollowedAthlete]
    
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
    @State var tabBarHidden = false
    @State var lastTrackedScrollOffset: CGFloat = 0
    @State var isTabBarSearchActive = false
    @State var homeHeaderScrollOffset: CGFloat = 0
    
    // MARK: - Computed Properties
    var dateParams: String {
        dateParams(from: dateRange)
    }
    
    // MARK: - Methods
    func clearSearch() {
        search.text = ""
        index = 1
        searchFieldFocused = false
    }
    
    private func dateParams(from selectedRange: Set<DateComponents>) -> String {
        var range = selectedRange.compactMap { components in
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

    var usesCustomNativeHeader: Bool {
        selectedTab == .standings || selectedTab == .results
    }

    var customHeaderTopPadding: CGFloat {
        usesCustomNativeHeader ? 120 : 0
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
