//
//  WatchStandingsListView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchStandingsListView: View {
    // MARK: - Properties
    @AppStorage("standingsWatchEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchEvent: StandingsEvent = .aa
    
    @StateObject var standingsApi = StandingsApi()
    
    @State var selectedEvent: StandingsEvent = .aa
    @State var initialLoad = true
    
    // MARK: - Body
    var body: some View {
        Form {
            Picker(
                "Select Event",
                selection: $selectedEvent,
                content: pickerContent
            )
            .pickerStyle(.navigationLink)
            
            Group {
                if standingsApi.loading {
                    WatchLogoLoader()
                } else {
                    ForEach(
                        standingsApi.standings,
                        id: \.place,
                        content: standingsCell
                    )
                }
            }
        }
        .navigationTitle("World Statndings")
        .onChange(of: selectedEvent) { oldValue, newValue in
            Task {
                await standingsApi.getStandings(for: newValue)
            }
        }
        .task {
            if initialLoad {
                selectedEvent = standingsWatchEvent
                await standingsApi.getStandings(for: standingsWatchEvent)
                initialLoad = false
            }
        }
    }
    
    // MARK: - View Methods
    func pickerContent() -> some View {
        let events = StandingsEvent.allCases.filter { $0.rawValue != "GB" && $0.rawValue != "LB" }

        return ForEach(events, content: pickerCell)
    }
    
    func pickerCell(_ event: StandingsEvent) -> some View {
        Text(event.title)
            .tag(event)
    }
    
    func standingsCell(_ position: Position) -> some View {
        HStack {
            Text(position.place.string)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.appSecondary)
                .padding(.trailing, 6)
            
            VStack(alignment: .leading) {
                Text(position.name)
                    .font(.headline)
                
                Text(position.hometownDisplay)
                    .font(.caption2)
                
                Text(position.earnings.currencyABS)
            }
        }
    }
}

struct WatchHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchStandingsListView(selectedEvent: .aa)
        }
    }
}
