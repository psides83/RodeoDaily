//
//  RodeoDailyWatchWidgets.swift
//  RodeoDailyWatchWidgets
//
//  Created by Payton Sides on 2/20/23.
//

import WidgetKit
import SwiftUI

struct WatchStandingsProvider: IntentTimelineProvider {
    typealias Intent = ConfigurationIntent
    
    public typealias Entry = WatchStandingsWidgetEntry
    
    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        return recommendedIntents()
            .map { intent in
                return IntentRecommendation(intent: intent, description: intent.widgetEvent!.displayString)
            }
    }
    
    func placeholder(in context: Context) -> WatchStandingsWidgetEntry {
        WatchStandingsWidgetEntry(date: Date(), configuration: ConfigurationIntent(), standings: exampleData[0])
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WatchStandingsWidgetEntry) -> ()) {
        Task {
            
//            @AppStorage("standingsWatchWidgetEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchWidgetEvent: StandingsEvent = .aa
                        
            await WatchStandingsWidgetApi().getStandings(event: configuration.widgetEvent?.identifier ?? "AA") { result in
                let entry = WatchStandingsWidgetEntry(date: Date(), configuration: configuration, standings: result[0])
                completion(entry)
            }
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            
//            @AppStorage("standingsWatchWidgetEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchWidgetEvent: StandingsEvent = .aa
            
            await WatchStandingsWidgetApi().getStandings(event: configuration.widgetEvent?.identifier ?? "AA") { result in
                
//                print(standingsWatchWidgetEvent)
                
                var entries = [WatchStandingsWidgetEntry]()
                
                for i in 0..<15 {
                    entries.append(WatchStandingsWidgetEntry(date: .now.advanced(by: TimeInterval(15 * (i + 1))), configuration: configuration, standings: result[i]))
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
    
    private func recommendedIntents() -> [ConfigurationIntent] {
        return StandingsEvent.allCases
            .map { event in
                let widgetEvent = WidgetEvent(identifier: event.id, display: event.title)
                let intent = ConfigurationIntent()
                intent.widgetEvent = widgetEvent
                return intent
            }
    }
    
    var exampleData: [Position] {
        return [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil)]
    }
}

struct WatchStandingsWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let standings: Position
}

struct WatchStandingsEntryView : View {
    var entry: WatchStandingsProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.configuration.widgetEvent?.displayString ?? "")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appSecondary)
                .padding(.leading, 10)
                .padding(.bottom, -4)
                .widgetAccentable()
            
            HStack {
                Text(entry.standings.place.string)
                    .font(.system(size: 18, weight: .semibold))
                
                VStack(alignment: .leading) {
                    Text(entry.standings.name)
                        .font(.system(size: 16, weight: .semibold))

                    Text(entry.standings.earnings.currencyABS)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Spacer()
            }
            .padding(6)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appPrimary, lineWidth: 2).widgetAccentable())
        }
        .preferredColorScheme(.dark)
    }
}

@main
struct RodeoDailyWatchWidgets: Widget {
    let kind: String = "watchStandingsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: WatchStandingsProvider()) { entry in
            WatchStandingsEntryView(entry: entry)
        }
        .configurationDisplayName("World Standings")
        .description("Current World Standings.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct RodeoDailyWatchWidgets_Previews: PreviewProvider {
    static var previews: some View {
        let standings = [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil)]
        
        WatchStandingsEntryView(entry: WatchStandingsWidgetEntry(date: Date(), configuration: ConfigurationIntent(), standings: standings[0]))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
