//
//  DaysheetAthleteWidget.swift
//  RodeoDailyWidget
//
//  Created by Codex on 5/16/26.
//

import SwiftUI
import WidgetKit

struct DaysheetAthleteWidget: Widget {
    let kind = "DaysheetAthleteWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: DaysheetAthleteWidgetIntent.self,
            provider: DaysheetAthleteWidgetProvider()
        ) { entry in
            DaysheetAthleteWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Entries")
        .description("Upcoming rodeos and times for a favorite athlete.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
