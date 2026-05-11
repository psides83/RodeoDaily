//
//  SettingsView.swift
//  RodeoDailyWatchApp
//
//  Created by Payton Sides on 2/21/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("standingsWatchEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchEvent: StandingsEvent = .aa
    
    @AppStorage("resultsWatchEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var resultsWatchEvent: Events.CodingKeys = .bb

    @AppStorage("watchQuickActionHapticsEnabled", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var quickActionHapticsEnabled = true
    
    var body: some View {
        Form {
            Section(
                header: Text("Default Events"),
                footer: Text("Standings and Results open to these events by default.")
            ) {
                Picker("Standings Event", selection: $standingsWatchEvent) {
                    let events = StandingsEvent.allCases.filter { $0.rawValue != "GB" && $0.rawValue != "LB" }
                    
                    ForEach(events) { event in
                        Text(event.title).tag(event)
                    }
                }
                
                Picker("Results Event", selection: $resultsWatchEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title).tag(event)
                    }
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
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
