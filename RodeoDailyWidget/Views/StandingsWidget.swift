//
//  RodeoDailyWidget.swift
//  RodeoDailyWidget
//
//  Created by Payton Sides on 2/3/23.
//

import WidgetKit
import SwiftUI

struct StandingsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StandingsWidgetEntry {
        StandingsWidgetEntry(date: Date(), standings: Array(exampleData.prefix(5)))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StandingsWidgetEntry) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
            
            await StandingsWidgetApi().getStandings() { result in
                let entry = StandingsWidgetEntry(date: Date(), standings: Array(exampleData.prefix(5)))
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StandingsWidgetEntry>) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
                        
            await StandingsWidgetApi().getStandings() { result in
                
                var entries = [StandingsWidgetEntry]()
                
                for i in 0..<5 {
                    let segment = i * 5
                    let segmentEnd = segment + 5
                    let positions = Array(result[segment..<segmentEnd])
                    
                    entries.append(StandingsWidgetEntry(date: .now.advanced(by: TimeInterval(60 * (i + 1))), standings: positions))
                }
                                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
    
    var exampleData: [Position] {
        return [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil)]
    }
}

struct StandingsWidgetEntry: TimelineEntry {
    let date: Date
    let standings: [Position]
}

struct StandingsWidgetEntryView : View {
    var entry: StandingsProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
    
    var body: some View {
        let standings = entry.standings
        
        VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text(favoriteStandingsEvent.title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            ForEach(standings, id: \.earnings) { position in
                
                Divider()
                    .overlay(Color.appSecondary)
                    .environment(\.colorScheme, .dark)
                
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.system(size: 18, weight: .semibold))
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(position.hometown ?? "")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        
                    }
            }
            
            HStack {
                Spacer()
                
                Text(NSLocalizedString("Updated ", comment: "") + entry.date.medium)
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.rdGreen).edgesIgnoringSafeArea(.all)
        .environment(\.colorScheme, .dark)
    }
}

struct StandingsWidget: Widget {
    let kind: String = "StandingsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StandingsProvider()) { entry in
            StandingsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Standings")
        .description("Current standings at a quick glance.")
        .supportedFamilies([.systemLarge])
    }
}

struct RodeoDailyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let standings = [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil)]
        
        
        Group {
            StandingsWidgetEntryView(entry: StandingsWidgetEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
