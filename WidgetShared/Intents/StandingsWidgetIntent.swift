//
//  WidgetStandingsIntent.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/2/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct StandingsWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    
    static var description = IntentDescription("Selects the event standings to display in the widget.")
    
    @Parameter(title: "Event", default: StandingsEvent.aa) var event: StandingsEvent
    
    init() {}
}
