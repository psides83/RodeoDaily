//
//  DaysheetAthleteWidgetEntry.swift
//  RodeoDailyWidget
//
//  Created by Codex on 5/16/26.
//

import Foundation
import WidgetKit

struct DaysheetAthleteWidgetEntry: TimelineEntry {
    let date: Date
    let athleteName: String
    let items: [DaysheetAthleteScheduleItem]
    let message: String?
    let athleteId: Int?
    let preferredEvent: String?

    var athleteBioURL: URL? {
        guard let athleteId, athleteId > 0 else { return nil }

        var components = URLComponents()
        components.scheme = "rodeodaily"
        components.host = "athlete"
        components.queryItems = [URLQueryItem(name: "id", value: athleteId.string)]
        if let preferredEvent, !preferredEvent.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "event", value: preferredEvent))
        }
        return components.url
    }

    static let placeholder = DaysheetAthleteWidgetEntry(
        date: Date(),
        athleteName: "Stetson Wright",
        items: DaysheetAthleteScheduleItem.samples,
        message: nil,
        athleteId: nil,
        preferredEvent: nil
    )
}

struct DaysheetAthleteScheduleItem: Identifiable, Hashable {
    let id: String
    let rodeoName: String
    let location: String
    let eventName: String
    let roundLabel: String
    let startDate: Date
    let contestantNumber: Int?
    let isTurnout: Bool

    var dateText: String {
        Self.dateFormatter.string(from: startDate)
    }

    var timeText: String {
        Self.timeFormatter.string(from: startDate)
    }

    var contestantText: String? {
        guard let contestantNumber else { return nil }
        return "No. \(contestantNumber)"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static let samples = [
        DaysheetAthleteScheduleItem(
            id: "sample-1",
            rodeoName: "Santa Rosa Roundup",
            location: "Vernon, TX",
            eventName: "Saddle Bronc",
            roundLabel: "Round 1",
            startDate: Date().addingTimeInterval(60 * 60 * 5),
            contestantNumber: 302,
            isTurnout: false
        ),
        DaysheetAthleteScheduleItem(
            id: "sample-2",
            rodeoName: "Reno Rodeo",
            location: "Reno, NV",
            eventName: "Bull Riding",
            roundLabel: "Round 2",
            startDate: Date().addingTimeInterval(60 * 60 * 29),
            contestantNumber: 188,
            isTurnout: false
        )
    ]
}
