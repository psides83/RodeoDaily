//
//  WatchStandingsWidgetMain.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/2/24.
//

import WidgetKit
import SwiftUI

struct StandingsARWidget: Widget {
    let kind: String = "AccessoryRectangularWidgetView"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: StandingsWidgetIntent.self,
            provider: StandingsProvider(widgetFamily: .accessoryRectangular)
        ) { entry in
            StandingsARWidgetView(entry: entry)
        }
        .configurationDisplayName("World Standings")
        .description("Current World Standings.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct PhoneStandingsARWidget: Widget {
    let kind: String = "PhoneARWidgetView"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: StandingsWidgetIntent.self,
            provider: StandingsProvider(widgetFamily: .accessoryRectangular)
        ) { entry in
            StandingsARWidgetView(entry: entry)
        }
        .configurationDisplayName("World Standings")
        .description("Current World Standings.")
        .supportedFamilies([.accessoryRectangular])
    }
}

