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
                        .listRowBackground(Color.clear)
                } else if standingsApi.standings.isEmpty {
                    ContentUnavailableView {
                        Label("No Standings", systemImage: "list.number")
                    } description: {
                        Text("Standings data is unavailable.")
                    }
                } else {
                    ForEach(
                        standingsApi.standings,
                        id: \.id,
                        content: standingsCell
                    )
                }
            }
        }
        .navigationTitle("World Standings")
        .onChange(of: selectedEvent) { oldValue, newValue in
            standingsWatchEvent = newValue
            Task {
                await standingsApi.getStandings(for: newValue)
            }
        }
        .refreshable {
            await standingsApi.getStandings(for: selectedEvent)
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
        let events = StandingsEvent.allCases

        return ForEach(events, content: pickerCell)
    }
    
    func pickerCell(_ event: StandingsEvent) -> some View {
        Text(event.title)
            .tag(event)
    }
    
    func standingsCell(_ position: Position) -> some View {
        HStack(spacing: 8) {
            Text(position.place.string)
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.appSecondary.opacity(0.9))
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(position.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                
                Text(position.hometownDisplay)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                
                Text(position.earnings.currencyABS)
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                WatchQuickAthleteStore.toggleFavorite(
                    athleteId: position.id,
                    name: position.name,
                    event: position.event
                )
                WatchQuickAthleteStore.playHapticForQuickAction()
            } label: {
                Label(
                    WatchQuickAthleteStore.isFavorite(athleteId: position.id) ? "Remove Favorite" : "Add Favorite",
                    systemImage: WatchQuickAthleteStore.isFavorite(athleteId: position.id) ? "star.slash" : "star"
                )
            }
            .tint(.yellow)

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
