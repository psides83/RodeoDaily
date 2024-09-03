//
//  StandingsWidgetLargeMain.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import SwiftUI
import WidgetKit

struct StandingsWidgetLarge: Widget {
    let kind: String = "StandingsWidgetLarge"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, 
            intent: StandingsWidgetIntent.self,
            provider: StandingsProvider(widgetFamily: .systemLarge)
        ) { entry in
            StandingsWidgetLargeView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Standings")
        .description("Current standings at a quick glance.")
        .supportedFamilies([.systemLarge])
    }
}
