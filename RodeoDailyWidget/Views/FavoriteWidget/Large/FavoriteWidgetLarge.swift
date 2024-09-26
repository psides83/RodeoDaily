//
//  FavoriteWidgetLarge.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import SwiftUI
import SwiftData
import WidgetKit

struct FavoriteWidgetLarge: Widget {
    let kind: String = "FavoriteWidgetLarge"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: FavoriteWidgetIntent.self,
            provider: FavoriteProvider()
        ) { entry in
            FavoriteWidgetLargeView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Athlete")
        .description("Your favorite athlete's info at a quick glance.")
        .supportedFamilies([.systemLarge])
    }
}


