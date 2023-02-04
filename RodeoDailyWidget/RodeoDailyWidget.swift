//
//  RodeoDailyWidget.swift
//  RodeoDailyWidget
//
//  Created by Payton Sides on 2/3/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), standings: exampleData)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
            
            await StandingsApi().getStandings(for: favoriteStandingsEvent, selectedYear: Date().yearInt) { result in
                let entry = SimpleEntry(date: Date(), standings: result)
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            
            @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
            
            await StandingsApi().getStandings(for: favoriteStandingsEvent, selectedYear: Date().yearInt) { result in
                let entry = SimpleEntry(date: Date(), standings: result)
                
                let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 24)))
                completion(timeline)
            }
        }
    }
    
    var exampleData: [Position] {
        return [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023)]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let standings: [Position]
}

struct RodeoDailyWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
    
    var body: some View {
        let standings = entry.standings.prefix(widgetFamily == .systemLarge ? 5 : 3)
        
        VStack(alignment: .leading, spacing: widgetFamily == .systemSmall ? 4 : 6) {
            
            HStack {
                Text(favoriteStandingsEvent.title)
                    .font(.system(size: widgetFamily == .systemSmall ? 20 : 24))
                    .fontWeight(.semibold)
                    .foregroundColor(.rdYellow)
                
                Spacer()
                
                Image("rodeo-daily-logo-white")
                    .resizable()
                    .frame(width: widgetFamily == .systemSmall ? 24 : 36, height: widgetFamily == .systemSmall ? 24 : 36)
            }
            
            ForEach(standings) { position in
                
                Divider().background(Color.rdYellow)
                
                switch widgetFamily {
                case .systemSmall:
                    HStack(spacing: 10) {
                        Text(position.place.string)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.rdYellow)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(position.earnings.currency)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                case .systemMedium:
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.rdYellow)
                        
                        Text(position.name)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                    }
                case .systemLarge:
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.rdYellow)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                            
                            Text(position.hometown)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                        
                    }
                default:
                    HStack {
                        Text(position.place.string)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.rdYellow)
                        
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
        .background(Color.rdGreen).edgesIgnoringSafeArea(.all)
    }
}

struct RodeoDailyWidget: Widget {
    let kind: String = "RodeoDailyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RodeoDailyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Rodeo Daily")
        .description("Current standings at a quick glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct RodeoDailyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let standings = [Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023), Position(id: 96898, firstName: "Stetson", lastName: "Wright", event: "AA", type: "world", hometown: "Milford, UT", nickName: "Stetson", imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png", earnings: 42626.6, points: 42626.6, place: 1, standingId: 291301, seasonYear: 2023)]
        
        
        Group {
            RodeoDailyWidgetEntryView(entry: SimpleEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            RodeoDailyWidgetEntryView(entry: SimpleEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            RodeoDailyWidgetEntryView(entry: SimpleEntry(date: Date(), standings: standings))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
