//
//  SettingsView.swift
//  RodeoDailyWatchApp
//
//  Created by Payton Sides on 2/21/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(
        FavoriteEventSettingsSync.favoriteStandingsEventKey,
        store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")
    )
    var favoriteStandingsEvent: StandingsEvent = .aa
    
    @AppStorage(
        FavoriteEventSettingsSync.favoriteResultsEventKey,
        store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")
    )
    var favoriteResultsEvent: Events.CodingKeys = .bb

    @AppStorage("watchQuickActionHapticsEnabled", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var quickActionHapticsEnabled = true
    
    var body: some View {
        Form {
            Section(
                header: Text("Default Events"),
                footer: Text("Standings and Results open to these events by default.")
            ) {
                Picker("Standings Event", selection: $favoriteStandingsEvent) {
                    ForEach(StandingsEvent.standingsFilterEvents) { event in
                        Text(event.title).tag(event)
                    }
                }
                .onChange(of: favoriteStandingsEvent) {
                    favoriteStandingsEvent = favoriteStandingsEvent.normalizedForStandingsFilter
                    FavoriteEventSettingsSync.shared.updateStandingsEvent(favoriteStandingsEvent)
                }
                
                Picker("Results Event", selection: $favoriteResultsEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title).tag(event)
                    }
                }
                .onChange(of: favoriteResultsEvent) {
                    FavoriteEventSettingsSync.shared.updateResultsEvent(favoriteResultsEvent)
                }
            }

            Section(
                header: Text("Quick Actions"),
                footer: Text("Use long-press on standings and results rows to add favorites or follows.")
            ) {
                Toggle("Haptic Feedback", isOn: $quickActionHapticsEnabled)

                LabeledContent("Favorites", value: WatchQuickAthleteStore.favorites().count.string)
                LabeledContent("Following", value: WatchQuickAthleteStore.followed().count.string)

                Button("Clear Favorites", role: .destructive) {
                    WatchQuickAthleteStore.clearFavorites()
                }
                .disabled(WatchQuickAthleteStore.favorites().isEmpty)

                Button("Clear Following", role: .destructive) {
                    WatchQuickAthleteStore.clearFollowed()
                }
                .disabled(WatchQuickAthleteStore.followed().isEmpty)
            }
        }
        .onAppear {
            favoriteStandingsEvent = favoriteStandingsEvent.normalizedForStandingsFilter
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
