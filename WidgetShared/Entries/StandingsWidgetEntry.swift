//
//  StandingsWidgetEntry.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import WidgetKit

struct StandingsWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: StandingsWidgetIntent
    let standings: [Position]?
    let position: Position?
}
