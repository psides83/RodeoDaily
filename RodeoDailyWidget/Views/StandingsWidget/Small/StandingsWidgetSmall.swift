//
//  StandingsWidgetSmall.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/26/23.
//

import WidgetKit
import SwiftUI



struct StandingsWidgetSmall: Widget {
    let kind: String = "StandingsWidgetSmall"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            provider: StandingsProvider(widgetFamily: .systemSmall)
        ) { entry in
            StandingsWidgetSmallView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Standings")
        .description("Current standings at a quick glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

