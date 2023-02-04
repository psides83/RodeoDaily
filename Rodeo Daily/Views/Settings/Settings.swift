//
//  Settings.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import SwiftUI
import WidgetKit

struct Settings: View {
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
    @AppStorage("favoriteResultssEvent") var favoriteResultssEvent: Events.CodingKeys = .bb
    
    var body: some View {
        Form {
            Section(header: Text("Favorites"), footer: Text("The selected Standings event will be used to populate the widget data.")) {
                Picker("Standings Event", selection: $favoriteStandingsEvent) {
                    ForEach(StandingsEvents.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteStandingsEvent) { newValue in
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                Picker("Results Event", selection: $favoriteResultssEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
