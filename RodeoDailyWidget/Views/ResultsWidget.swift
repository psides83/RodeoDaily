//
//  RodeoDailyWidget.swift
//  RodeoDailyWidget
//
//  Created by Payton Sides on 2/3/23.
//

import WidgetKit
import SwiftUI

struct ResultsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ResultsWidgetEntry {
        ResultsWidgetEntry(date: Date(), results: exampleData)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ResultsWidgetEntry) -> ()) {
        Task {
            
            @AppStorage("favoriteResultsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteResultsEvent: Events.CodingKeys = .bb
            
            await ResultsWidgetApi().loadRodeos(event: favoriteResultsEvent) { result in
                let entry = ResultsWidgetEntry(date: Date(), results: result)
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            
            @AppStorage("favoriteResultsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteResultsEvent: Events.CodingKeys = .bb
            
            await ResultsWidgetApi().loadRodeos(event: favoriteResultsEvent) { result in
                let entry = ResultsWidgetEntry(date: Date(), results: result)
                
                let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 12)))
                completion(timeline)
            }
        }
    }
    
    let exampleData = RodeoResult(id: 12582, city: "Fort Worth", state: "TX", name: "Fort Worth Stock Show & Rodeo", rounds: [RoundWinners(id: 1, round: "1", winners: [Winner(id: 213, contestantId: 3232, roundLabel: "1", name: "Caleb Smidt", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.2, score: 0.0, place: 1, round: 1), Winner(id: 213, contestantId: 3232, roundLabel: "1", name: "Caleb Smidt", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.2, score: 0.0, place: 1, round: 1), Winner(id: 213, contestantId: 3232, roundLabel: "1", name: "Caleb Smidt", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.2, score: 0.0, place: 1, round: 1)])])
}

struct ResultsWidgetEntry: TimelineEntry {
    let date: Date
    let results: RodeoResult
}

struct ResultsWidgetEntryView : View {
    var entry: ResultsProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @AppStorage("favoriteResultsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteResultsEvent: Events.CodingKeys = .bb
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: widgetFamily == .systemSmall ? 4 : 6) {

            HStack {
            Text(entry.results.city)
                    .font(.system(size: widgetFamily == .systemSmall ? 16 : 24))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Image("rodeo-daily-logo-white")
                    .resizable()
                    .frame(width: widgetFamily == .systemSmall ? 24 : 36, height: widgetFamily == .systemSmall ? 24 : 36)
            }
//
//            ForEach(entry.results.rounds, id: \.round) { round in
            let lastRound = entry.results.rounds.count - 1
            let round = entry.results.rounds[lastRound]
//
                Divider()
                    .overlay(Color.appSecondary)
                    .environment(\.colorScheme, .dark)
//
                switch widgetFamily {
                case .systemSmall:
                    VStack(alignment: .leading) {
                        Text("Round \(round.round)")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                            .environment(\.colorScheme, .dark)
                        
                        ForEach(round.winners.prefix(4)) { winner in
                            HStack {
                                Text(winner.place.string)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.appSecondary)
                                    .environment(\.colorScheme, .dark)
                                                                
                                    Text(winner.name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                Spacer()
                                
                                Text(winner.result)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
//
//                        VStack(alignment: .leading) {
//                            Text(position.name)
//                                .foregroundColor(.white)
//                                .font(.system(size: 14, weight: .medium))
//
//                            Text(position.earnings.currency)
//                                .font(.caption)
//                                .foregroundColor(.white)
//                        }
                    }

                case .systemMedium:
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Round \(round.round)")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                            .environment(\.colorScheme, .dark)
                        
                        ForEach(round.winners) { winner in
                            HStack {
                                Text(winner.place.string)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.appSecondary)
                                    .environment(\.colorScheme, .dark)
                                                                
                                    Text(winner.name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                Spacer()
                                
                                Text(winner.result)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
//
//                        VStack(alignment: .leading) {
//                            Text(position.name)
//                                .foregroundColor(.white)
//                                .font(.system(size: 14, weight: .medium))
//
//                            Text(position.earnings.currency)
//                                .font(.caption)
//                                .foregroundColor(.white)
//                        }
                    }
                case .systemLarge:
                    HStack(spacing: 16) {
                        Text("")
//                            .font(.title3)
//                            .fontWeight(.medium)
//                            .foregroundColor(.appSecondary)
//                            .environment(\.colorScheme, .dark)
//
//                        VStack(alignment: .leading) {
//                            Text(position.name)
//                                .foregroundColor(.white)
//                                .font(.system(size: 20, weight: .medium))
//
//                            Text(position.hometown ?? "")
//                                .foregroundColor(.white)
//                                .font(.system(size: 16))
//                        }
//
//                        Spacer()
//
//                        Text(position.earnings.currency)
//                            .foregroundColor(.white)
//                            .font(.system(size: 18))

                    }
                default:
                    HStack {
                        Text("")
//                            .font(.headline)
//                            .fontWeight(.medium)
//                            .foregroundColor(.appSecondary)
//
//                        Text(position.name)
//                            .foregroundColor(.white)
//                            .font(.system(size: 18, weight: .semibold))
//
//                        Spacer()
//
//                        Text(position.earnings.currency)
//                            .font(.subheadline)
//                            .foregroundColor(.white)
                    }
                }
//            }
//            if widgetFamily == .systemLarge {
//                HStack {
//                    Spacer()
//
//                    Text("Updated \(entry.date.medium)")
//                        .foregroundColor(.white)
//                        .font(.caption)
//                }
//            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appPrimary).edgesIgnoringSafeArea(.all)
        .environment(\.colorScheme, .light)
    }
}

struct ResultsWidget: Widget {
    let kind: String = "ResultsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ResultsProvider()) { entry in
            ResultsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Rodeo Daily")
        .description("Current major results at a quick glance.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ResultsWidget_Previews: PreviewProvider {
    static var previews: some View {
        let exampleData = RodeoResult(id: 12582, city: "Fort Worth", state: "TX", name: "Fort Worth Stock Show & Rodeo", rounds: [RoundWinners(id: 1, round: "1", winners: [Winner(id: 213, contestantId: 3232, roundLabel: "1", name: "Caleb", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.2, score: 0.0, place: 1, round: 1)]), RoundWinners(id: 2, round: "2", winners: [Winner(id: 213, contestantId: 3232, roundLabel: "2", name: "Caleb Smidt", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 7.6, score: 0.0, place: 1, round: 1), Winner(id: 102, contestantId: 3232, roundLabel: "2", name: "Ty Harris", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.0, score: 0.0, place: 2, round: 2), Winner(id: 345, contestantId: 3232, roundLabel: "2", name: "Shad Mayfield", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.2, score: 0.0, place: 3, round: 2), Winner(id: 876, contestantId: 3232, roundLabel: "2", name: "Shane Hanchey", hometown: "Somewhere, TX", imageUrl: nil, payoff: 1200.00, time: 8.8, score: 0.0, place: 4, round: 2)])])
    
        
        Group {
//            ResultsWidgetEntryView(entry: ResultsWidgetEntry(date: Date(), results: exampleData))
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ResultsWidgetEntryView(entry: ResultsWidgetEntry(date: Date(), results: exampleData))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ResultsWidgetEntryView(entry: ResultsWidgetEntry(date: Date(), results: exampleData))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
