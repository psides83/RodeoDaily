//
//  DaysheetAthleteWidgetIntent.swift
//  RodeoDaily
//
//  Created by Codex on 5/16/26.
//

import AppIntents
import WidgetKit

struct DaysheetAthleteWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Daysheet Athlete"

    static var description = IntentDescription("Selects the favorite athlete to track in upcoming daysheets.")

    @Parameter(title: "Athlete") var athlete: WidgetAthleteEntity?

    init() {}
}
