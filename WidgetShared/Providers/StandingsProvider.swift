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
            position: widgetFamily != .accessoryRectangular ? nil : sampleData[0]
        )
    }
    
    func snapshot(for configuration: StandingsWidgetIntent, in context: Context) async -> StandingsWidgetEntry {
        @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa

        var result: [Position] = []
        
        var config: StandingsWidgetIntent {
            if widgetFamily == .accessoryRectangular {
                var config = configuration
                
                config.event = favoriteStandingsEvent
                
                return config
            } else {
                return configuration
            }
        }
        
        await StandingsWidgetApi().getStandings(event: config.event) { standings in
            result = standings
        }
        
        return Entry(
            date: Date(),
            configuration: config,
            standings: widgetFamily != .accessoryRectangular ? Array(result.prefix(numberOfResults)) : nil,
            position: widgetFamily != .accessoryRectangular ? nil : result[0]
        )
    }
    
    func timeline(for configuration: StandingsWidgetIntent, in context: Context) async -> Timeline<StandingsWidgetEntry> {
        @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
        var entries: [Entry] = []
        
        var config: StandingsWidgetIntent {
            if widgetFamily == .accessoryRectangular {
                var config = configuration
                
                config.event = favoriteStandingsEvent
                
                return config
            } else {
                return configuration
            }
        }

        await StandingsWidgetApi().getStandings(event: config.event) { result in
            switch widgetFamily {
            case .systemSmall, .systemMedium:
                for i in 0..<5 {
                    let segment = i * 3
                    let segmentEnd = segment + 3
                    let positions = Array(result[segment..<segmentEnd])
                    
                    entries.append(Entry(
                        date: .now.advanced(by: TimeInterval(60 * (i + 1))),
                        configuration: config,
                        standings: positions,
                        position: nil)
                    )
                }
            case .systemLarge:
                for i in 0..<5 {
                    let segment = i * 5
                    let segmentEnd = segment + 5
                    let positions = Array(result[segment..<segmentEnd])
                    
                    entries.append(Entry(
                        date: .now.advanced(by: TimeInterval(60 * (i + 1))),
                        configuration: config,
                        standings: positions,
                        position: nil)
                    )
                }
            case .systemExtraLarge:
                for i in 0..<5 {
                    let segment = i * 5
                    let segmentEnd = segment + 5
                    let positions = Array(result[segment..<segmentEnd])
                    
                    entries.append(Entry(
                        date: .now.advanced(by: TimeInterval(60 * (i + 1))),
                        configuration: config,
                        standings: positions,
                        position: nil)
                    )
                }
            case .accessoryRectangular:
                for i in 0..<15 {
                    entries.append(Entry(
                        date: .now.advanced(by: TimeInterval(15 * (i + 1))),
                        configuration: config,
                        standings: nil,
                        position: result[i])
                    )
                }
            default:
                for i in 0..<5 {
                    let segment = i * 5
                    let segmentEnd = segment + 5
                    let positions = Array(result[segment..<segmentEnd])
                    
                    entries.append(Entry(
                        date: .now.advanced(by: TimeInterval(60 * (i + 1))),
                        configuration: config,
                        standings: positions,
                        position: nil)
                    )
                }
            }
            
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    func recommendations() -> [AppIntentRecommendation<StandingsWidgetIntent>] {
        let events = StandingsEvent.allCases
#if os(watchOS)
            .filter { $0.rawValue != "GB" && $0.rawValue != "LB" }
#endif
        
        return events
            .map { event in
                let standingsIntent = StandingsWidgetIntent()
                standingsIntent.event = event
                let intent = AppIntentRecommendation(intent: standingsIntent, description: standingsIntent.event.title)
                return intent
            }
    }
}
