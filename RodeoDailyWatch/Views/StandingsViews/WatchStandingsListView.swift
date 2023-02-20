//
//  WatchStandingsListView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchStandingsListView: View {
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
    
    @StateObject var standingsApi = StandingsApi()
    
    @State var selectedEvent: StandingsEvent = .aa
    
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
        .onChange(of: selectedEvent) { newValue in
            Task {
                await standingsApi.getStandings(for: newValue)
            }
        }
        .task {
            await standingsApi.getStandings(for: favoriteStandingsEvent)
        }
    }
    
    // MARK: - View Methods
    func pickerContent() -> some View {
        print(favoriteStandingsEvent)
        return ForEach(StandingsEvent.allCases, id: \.self, content: pickerCell)
    }
    
    func pickerCell(_ event: StandingsEvent) -> some View {
        Text(event.title)
            .tag(event)
    }
    
    func standingsCell(_ position: Position) -> some View {
        HStack {
            Text(position.place.string)
            
            VStack(alignment: .leading) {
                Text(position.name)
                
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
