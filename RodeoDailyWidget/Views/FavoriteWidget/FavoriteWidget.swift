//
//  FavoriteWidget.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import SwiftUI
import WidgetKit

struct FavoriteWidget: Widget {
    let kind: String = "FavoriteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoriteProvider()) { entry in
            FavoriteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Athlete")
        .description("Your favorite athlete's info at a quick glance.")
        .supportedFamilies([.systemLarge])
    }
}


