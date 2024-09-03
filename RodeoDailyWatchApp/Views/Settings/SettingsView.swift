//
//  SettingsView.swift
//  RodeoDailyWatchApp
//
//  Created by Payton Sides on 2/21/23.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage("standingsWatchEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchEvent: StandingsEvent = .aa
    
    @AppStorage("resultsWatchEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var resultsWatchEvent: Events.CodingKeys = .bb
    
    var body: some View {
        Form {
            Section(header: Text("Favorite Event"), footer: Text("When the Standings or Results section is opened, they will load the event selected here.")) {
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
            
//            Section(header: Text("Results Event"), footer: Text("This setting loads the Results to this event")) {
//                Picker("Select Event", selection: $resultsWatchEvent) {
//                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
//                        Text(event.title).tag(event)
//                    }
//                }
//            }
        }.navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
