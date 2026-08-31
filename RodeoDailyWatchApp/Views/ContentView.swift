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

    enum ViewSelection: String, CaseIterable, Identifiable {
        case standings = "World Standings"
        case results = "Rodeo Results"
        case schedule = "Schedule"
        case settings = "Settings"
        
        var id: String { rawValue }

        var subtitle: String {
            switch self {
            case .standings:
                return "Rankings by event"
            case .results:
                return "Recent rodeos"
            case .schedule:
                return "Upcoming rodeos"
            case .settings:
                return "Favorite events"
            }
        }

        var systemImage: String {
            switch self {
            case .standings:
                return "list.number"
            case .results:
                return "trophy"
            case .schedule:
                return "calendar"
            case .settings:
                return "gearshape"
            }
        }
    }
    
    @State var selectedView: ViewSelection = .standings
    @State var showingEvetns = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ViewSelection.allCases, id: \.self, content: viewSelectionListRow)
                } header: {
                    WatchHomeHeader()
                }
            }
            .listStyle(.carousel)
        }
        .tint(.appSecondary)
        .colorScheme(.dark)
    }

    // MARK: - View Methods
    func viewSelectionListRow(_ view: ViewSelection) -> some View {
        NavigationLink {
            switch view {
            case .standings:
                WatchStandingsListView()
            case .results:
                WatchRodeosListView()
            case .schedule:
                WatchScheduleListView()
            case .settings:
                SettingsView()
            }
        } label: {
            WatchHomeRow(
                title: NSLocalizedString(view.rawValue, comment: ""),
                subtitle: view.subtitle,
                systemImage: view.systemImage
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
