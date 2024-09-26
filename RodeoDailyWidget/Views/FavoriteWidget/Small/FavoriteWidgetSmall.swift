//
//  FavoriteWidgetLarge.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import SwiftUI
import SwiftData
import WidgetKit

struct FavoriteWidgetSmall: Widget {
    let kind: String = "FavoriteWidgetSmall"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: FavoriteWidgetIntent.self,
            provider: FavoriteProvider()
        ) { entry in
            FavoriteWidgetSmallView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Athlete")
        .description("Your favorite athlete's info at a quick glance.")
        .supportedFamilies([.systemSmall])
    }
}


