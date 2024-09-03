//
//  Settings.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage("favoriteStandingsEvent",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteStandingsEvent: StandingsEvent = .aa
    
    @AppStorage("favoriteResultsEvent",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteResultsEvent: Events.CodingKeys = .bb
    
    @AppStorage("favoriteAthlete",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteAthlete: FavoriteAthlete? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Favorites"),
                    footer: Text("The selected events will be used to populate the lock screen widget data and load in the respective tab when the app opens.")) {
                Picker("Standings Event", selection: $favoriteStandingsEvent) {
                    ForEach(StandingsEvent.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteStandingsEvent) { newValue in
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                Picker("Results Event", selection: $favoriteResultsEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteResultsEvent) { newValue in
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            
            if favoriteAthlete != nil {
                Section(header: Text("Favorite Athlete Widget"),
                        footer: Text("Unfortunately, setting a Favorite Athlete for Barrel Reacing and Breakaway Roping is unvailavble at this time.")) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text(favoriteAthlete?.name ?? "")
                            
                            Spacer()
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(.appSecondary)
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
