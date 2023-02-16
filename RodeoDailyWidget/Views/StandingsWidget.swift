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
        StandingsWidgetEntry(date: Date(), standings: exampleData)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StandingsWidgetEntry) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
            
            await StandingsWidgetApi().getStandings(for: favoriteStandingsEvent, selectedYear: Date().yearInt) { result in
                let entry = StandingsWidgetEntry(date: Date(), standings: result)
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
            
            await StandingsWidgetApi().getStandings(for: favoriteStandingsEvent, selectedYear: Date().yearInt) { result in
                let entry = StandingsWidgetEntry(date: Date(), standings: result)
                
                let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 12)))
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
    
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
    
    var body: some View {
        let standings = entry.standings.prefix(widgetFamily == .systemLarge ? 5 : 3)
        
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
                    .environment(\.colorScheme, .dark)
                
                switch widgetFamily {
                case .systemSmall:
                    HStack(spacing: 10) {
                        Text(position.place.string)
                            .font(.system(size: 16, weight: .semibold))
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                            .environment(\.colorScheme, .dark)
                        
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
                            .environment(\.colorScheme, .dark)
                        
                        Text(position.name)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                    }
                case .systemLarge:
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.system(size: 18, weight: .semibold))
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                            .environment(\.colorScheme, .dark)
                        
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
            if widgetFamily == .systemLarge {
                HStack {
                    Spacer()
                    
                    Text("Updated \(entry.date.medium)")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appPrimary).edgesIgnoringSafeArea(.all)
        .environment(\.colorScheme, .light)
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct RodeoDailyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let standings = [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023, tourId: nil, circuitId: nil)]
        
        
        Group {
            StandingsWidgetEntryView(entry: StandingsWidgetEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            StandingsWidgetEntryView(entry: StandingsWidgetEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            StandingsWidgetEntryView(entry: StandingsWidgetEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
