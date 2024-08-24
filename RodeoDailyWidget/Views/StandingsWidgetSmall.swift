//
//  StandingsWidgetSmall.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/26/23.
//

import WidgetKit
import SwiftUI

struct StandingsSmallProvider: TimelineProvider {
    func placeholder(in context: Context) -> StandingsWidgetSmallEntry {
        StandingsWidgetSmallEntry(date: Date(), standings: Array(exampleData.prefix(3)))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StandingsWidgetSmallEntry) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
            
            await StandingsWidgetApi().getStandings() { result in
                let entry = StandingsWidgetSmallEntry(date: Date(), standings: Array(result.prefix(3)))
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StandingsWidgetSmallEntry>) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
                        
            await StandingsWidgetApi().getStandings() { result in
                
                var entries = [StandingsWidgetSmallEntry]()
                
                for i in 0..<5 {
                    let segment = i * 3
                    let segmentEnd = segment + 3
                    let positions = Array(result[segment..<segmentEnd])
                    
                    entries.append(StandingsWidgetSmallEntry(date: .now.advanced(by: TimeInterval(60 * (i + 1))), standings: positions))
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

struct StandingsWidgetSmallEntry: TimelineEntry {
    let date: Date
    let standings: [Position]
}

struct StandingsWidgetSmallEntryView : View {
    var entry: StandingsSmallProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
    
    var body: some View {
        let standings = entry.standings
        
        VStack(alignment: .leading, spacing: widgetFamily == .systemSmall ? 4 : 6) {
            
            HStack {
                Text(favoriteStandingsEvent.title)
                    .font(.system(size: widgetFamily == .systemSmall ? 16 : 22, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: widgetFamily == .systemSmall ? 24 : 32, height: widgetFamily == .systemSmall ? 24 : 32)
            }
            
            ForEach(standings, id: \.earnings) { position in
                
                Divider()
                    .overlay(Color.appSecondary)
                
                switch widgetFamily {
                case .systemSmall:
                    HStack(spacing: 10) {
                        Text(position.place.string)
                            .font(.system(size: 16, weight: .semibold))
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(position.earnings.currency)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                case .systemMedium:
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.system(size: 16, weight: .semibold))
                            .fontWeight(.semibold)
                            .foregroundColor(.appSecondary)
                        
                        Text(position.name)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                    }
                default:
                    HStack {
                        Text(position.place.string)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                        
                        Text(position.name)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.rdGreen).edgesIgnoringSafeArea(.all)
        .environment(\.colorScheme, .dark)
    }
}

struct StandingsWidgetSmall: Widget {
    let kind: String = "StandingsWidgetSmall"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StandingsSmallProvider()) { entry in
            StandingsWidgetSmallEntryView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Standings")
        .description("Current standings at a quick glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct RodeoDailyWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        let standings = [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil)]
        
        
        Group {
            StandingsWidgetSmallEntryView(entry: StandingsWidgetSmallEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            StandingsWidgetSmallEntryView(entry: StandingsWidgetSmallEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
