//
//  StandingsWidgetSmallProvider.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import SwiftUI
import WidgetKit

struct StandingsProvider: AppIntentTimelineProvider {
    typealias Intent = StandingsWidgetIntent
    
    public typealias Entry = StandingsWidgetEntry
    
    let sampleData = Array(WidgetSampleData().standingsSampleData.prefix(3))
    
    var widgetFamily: WidgetFamily

    var numberOfResults: Int {
        switch widgetFamily {
        case .systemSmall, .systemMedium:
            return 3
        case .systemLarge:
            return 5
        case .systemExtraLarge:
            return 5
        case .accessoryRectangular:
            return 1
        default: return 5
        }
    }
    
    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            configuration: Intent(),
            standings: widgetFamily != .accessoryRectangular ? sampleData : nil,
            position: widgetFamily != .accessoryRectangular ? nil : sampleData.first
        )
    }
    
    func snapshot(for configuration: StandingsWidgetIntent, in context: Context) async -> StandingsWidgetEntry {
        var result: [Position] = []

        await StandingsWidgetApi().getStandings(event: configuration.event) { standings in
            result = standings
        }

        let fallback = sampleData.first
        let firstPosition = result.first ?? fallback

        return Entry(
            date: Date(),
            configuration: configuration,
            standings: widgetFamily != .accessoryRectangular ? Array(result.prefix(numberOfResults)) : nil,
            position: widgetFamily != .accessoryRectangular ? nil : firstPosition
        )
    }
    
    func timeline(for configuration: StandingsWidgetIntent, in context: Context) async -> Timeline<StandingsWidgetEntry> {
        var entries: [Entry] = []

        await StandingsWidgetApi().getStandings(event: configuration.event) { result in
            switch widgetFamily {
            case .systemSmall, .systemMedium:
                appendStandingsEntries(
                    into: &entries,
                    standings: result,
                    chunkSize: 3,
                    configuration: configuration
                )
            case .systemLarge:
                appendStandingsEntries(
                    into: &entries,
                    standings: result,
                    chunkSize: 5,
                    configuration: configuration
                )
            case .systemExtraLarge:
                appendStandingsEntries(
                    into: &entries,
                    standings: result,
                    chunkSize: 5,
                    configuration: configuration
                )
            case .accessoryRectangular:
                let positions = result.isEmpty ? sampleData : result
                if positions.isEmpty {
                    entries.append(Entry(
                        date: .now,
                        configuration: configuration,
                        standings: nil,
                        position: nil
                    ))
                } else {
                    for i in 0..<min(positions.count, 15) {
                        entries.append(Entry(
                            date: .now.advanced(by: TimeInterval(15 * i)),
                            configuration: configuration,
                            standings: nil,
                            position: positions[i])
                        )
                    }
                }
            default:
                appendStandingsEntries(
                    into: &entries,
                    standings: result,
                    chunkSize: 5,
                    configuration: configuration
                )
            }
            
        }

        if entries.isEmpty {
            entries.append(Entry(
                date: .now,
                configuration: configuration,
                standings: widgetFamily == .accessoryRectangular ? nil : sampleData,
                position: widgetFamily == .accessoryRectangular ? sampleData.first : nil
            ))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
    func recommendations() -> [AppIntentRecommendation<StandingsWidgetIntent>] {
        let events = StandingsEvent.allCases
//#if os(watchOS)
//            .filter { $0.rawValue != "GB" && $0.rawValue != "LB" }
//#endif
        
        return events
            .map { event in
                let standingsIntent = StandingsWidgetIntent()
                standingsIntent.event = event
                let intent = AppIntentRecommendation(intent: standingsIntent, description: standingsIntent.event.title)
                return intent
            }
    }

    private func appendStandingsEntries(
        into entries: inout [Entry],
        standings: [Position],
        chunkSize: Int,
        configuration: StandingsWidgetIntent
    ) {
        let data = standings.isEmpty ? sampleData : standings
        guard !data.isEmpty else { return }

        let chunks = stride(from: 0, to: data.count, by: chunkSize).map { start in
            Array(data[start..<min(start + chunkSize, data.count)])
        }

        let limitedChunks = Array(chunks.prefix(5))
        for (index, chunk) in limitedChunks.enumerated() {
            entries.append(Entry(
                date: .now.advanced(by: TimeInterval(60 * index)),
                configuration: configuration,
                standings: chunk,
                position: nil
            ))
        }
    }
}
