//
//  ContentView.swift
//  RodeoDailyWatch Watch App
//
//  Created by Payton Sides on 2/18/23.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("standingsWatchWidgetEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchWidgetEvent: StandingsEvent = .aa

    enum ViewSelection: String, CaseIterable, Identifiable {
        case standings = "World Standings"
        case results = "Rodeo Results"
        case settings = "Settings"
        
        var id: String { rawValue }
    }
    
    @State var selectedView: ViewSelection = .standings
    @State var showingEvetns = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form(content: viewSelectionListSection)
        }
        .tint(.appSecondary)
        .colorScheme(.dark)
    }
    
    // MARK: - View Methods
    func listHeader() -> some View {
        HStack {
            WatchLogo(size: 28)
            
            Text("Rodeo Daily")
                .font(.headline)
        }
    }
    
    func viewSelectionListSection() -> some View {
        Section(
            header:
                HStack {
                    WatchLogo(size: 28)
                    
                    Text("Rodeo Daily")
                        .font(.headline).textCase(.none)
                },
            content: viewSelectionForEach
        )
    }
    
    func viewSelectionForEach() -> some View {
        ForEach(ViewSelection.allCases, id: \.self, content: viewSelectionListRow)
    }
    
    func viewSelectionListRow(_ view: ViewSelection) -> some View {
        NavigationLink(NSLocalizedString(view.rawValue, comment: "")) {
            switch view {
            case .standings:
                WatchStandingsListView()
            case .results:
                WatchRodeosListView()
            case .settings:
                SettingsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
