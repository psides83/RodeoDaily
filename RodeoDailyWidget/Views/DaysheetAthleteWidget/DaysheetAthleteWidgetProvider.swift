//
//  DaysheetAthleteWidgetProvider.swift
//  RodeoDailyWidget
//
//  Created by Codex on 5/16/26.
//

import WidgetKit

struct DaysheetAthleteWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = DaysheetAthleteWidgetIntent
    typealias Entry = DaysheetAthleteWidgetEntry

    private func numberOfResults(for family: WidgetFamily) -> Int {
        switch family {
        case .systemMedium:
            return 2
        case .systemLarge:
            return 5
        default:
            return 2
        }
    }

    func placeholder(in context: Context) -> Entry {
        .placeholder
    }

    func snapshot(for configuration: DaysheetAthleteWidgetIntent, in context: Context) async -> Entry {
        guard !context.isPreview else { return .placeholder }
        return await entry(for: configuration, family: context.family)
    }

    func timeline(for configuration: DaysheetAthleteWidgetIntent, in context: Context) async -> Timeline<Entry> {
        let entries = await timelineEntries(for: configuration, family: context.family)
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func entry(for configuration: DaysheetAthleteWidgetIntent, family: WidgetFamily) async -> Entry {
        guard let athlete = configuration.athlete else {
            return Entry(
                date: Date(),
                athleteName: "Favorite Athlete",
                items: [],
                message: "Choose an athlete to see where they appear in upcoming rodeo day sheets.",
                athleteId: nil,
                preferredEvent: nil
            )
        }

        let items = await DaysheetAthleteWidgetApi().loadSchedule(for: athlete)
        return Entry(
            date: Date(),
            athleteName: athlete.name,
            items: Array(items.prefix(numberOfResults(for: family))),
            message: items.isEmpty ? "This athlete does not appear in any current day sheets." : nil,
            athleteId: athlete.athleteId,
            preferredEvent: athlete.event
        )
    }

    private func timelineEntries(for configuration: DaysheetAthleteWidgetIntent, family: WidgetFamily) async -> [Entry] {
        guard let athlete = configuration.athlete else {
            return [
                Entry(
                    date: Date(),
                    athleteName: "Favorite Athlete",
                    items: [],
                    message: "Choose an athlete to see where they appear in upcoming rodeo day sheets.",
                    athleteId: nil,
                    preferredEvent: nil
                )
            ]
        }

        let chunkSize = numberOfResults(for: family)
        let items = await DaysheetAthleteWidgetApi().loadSchedule(for: athlete)
        guard !items.isEmpty else {
            return [
                Entry(
                    date: Date(),
                    athleteName: athlete.name,
                    items: [],
                    message: "This athlete does not appear in any current day sheets.",
                    athleteId: athlete.athleteId,
                    preferredEvent: athlete.event
                )
            ]
        }

        let chunks = stride(from: 0, to: items.count, by: chunkSize).map { start in
            Array(items[start..<min(start + chunkSize, items.count)])
        }

        return chunks.enumerated().map { index, chunk in
            Entry(
                date: .now.advanced(by: TimeInterval(60 * index)),
                athleteName: athlete.name,
                items: chunk,
                message: nil,
                athleteId: athlete.athleteId,
                preferredEvent: athlete.event
            )
        }
    }
}
