//
//  FavoriteWidget.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import WidgetKit
import SwiftUI

struct FavoriteProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavoriteWidgetEntry {
        FavoriteWidgetEntry(date: Date(), bio: exampleData, event: .td)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FavoriteWidgetEntry) -> ()) {
        Task {
            
            @AppStorage("favoriteAthlete", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthlete: FavoriteAthlete? = nil
                        
            await FavoriteWidgetApi().loadBio(for: favoriteAthlete?.id ?? 96898) { bio in
                let entry = FavoriteWidgetEntry(date: Date(), bio: bio, event: .td)
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            
            @AppStorage("favoriteAthlete", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthlete: FavoriteAthlete? = nil
            
            await FavoriteWidgetApi().loadBio(for: favoriteAthlete?.id ?? 96898) { bio in
                let entry = FavoriteWidgetEntry(date: Date(), bio: bio, event: .td)
                
                print(bio)
                
                let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 12)))
                completion(timeline)
            }
        }
    }
    
    let exampleData = BioData(results: [BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 674, eventType: "TD", place: 3, payoff: 1250.00, time: 8.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023)], career: [Career(season: 2023, eventType: "TD", earnings: 100000.00, worldTitles: 4, nfrQualified: false, timedStatistics: nil)], rankings: [Ranking(rank: "#1", rankType: "World", eventName: "Tie-down Roping", season: 2023, tourId: nil, circuitId: nil)], earnings: ["2023": [Earning(seasonYear: 2023, earnings: 100000.00, eventType: "TD")]], contestantId: 70406, firstName: "Caleb", lastName: "Smidt", nickName: "Caleb", hometown: "Somewhere, TX", imageUrl: "", featured: false, birthDate: "1994-2-27", age: 31, totalEarnings: 1200987.87, yearEarnings: 100000, worldTitles: 4, nfrQualifications: 7, dateJoined: "2012-1-12", eventTypes: ["TD, TR"], biographyText: "")
}

struct FavoriteWidgetEntry: TimelineEntry {
    let date: Date
    let bio: BioData
    let event: Events.CodingKeys
}

struct FavoriteWidgetEntryView : View {
    var entry: FavoriteProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.sizeCategory) var deviceSize
    
    var latestResults: ArraySlice<BioResult> {
        return entry.bio.results.filter({ $0.eventType == entry.event.rawValue }).sorted(by: { $0.endDate > $1.endDate }).prefix(4)
    }
    
    var currentYearEarnings: String {
        return entry.bio.career.filter({ $0.season == Date().yearInt && $0.eventType == entry.event.rawValue })[0].earnings.currencyABS
    }
    
    var currentYearRank: String {
        let rankData = entry.bio.rankings.filter({ $0.season == Date().yearInt && $0.eventName.localizedCaseInsensitiveContains(entry.event.title.localizedLowercase) })[0]
        
        return "\(rankData.rank) in \(rankData.eventName) with \(currentYearEarnings)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text(entry.bio.name)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
                        
            Text(currentYearRank)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text("Latest Results")
                .foregroundColor(.appSecondary)
                .font(.system(size: 16, weight: .semibold))
                .environment(\.colorScheme, .dark)
        
                ForEach(latestResults, id: \.rodeoResultId) { result in
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Divider()
                            .overlay(Color.appSecondary)
                            .environment(\.colorScheme, .dark)
                        
                        HStack(alignment: .center, spacing: 6) {
                            Text(result.location)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                            
                            Text(result.endDate.medium)
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Spacer()
                                
                            Text(result.roundDisplay)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 20) {
                            Text(result.placeDisplay)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .frame(width: 40, alignment: .leading)
                            
                            Spacer()
                            
                            Text(result.resultDisplay)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .frame(width: 40)
                            
                            Spacer()
                            
                            Text(result.payoutDisplay)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .frame(width: 100, alignment: .trailing)
                        }
                    }
                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appPrimary).edgesIgnoringSafeArea(.all)
        .environment(\.colorScheme, .light)
    }
}

struct FavoriteWidget: Widget {
    let kind: String = "FavoriteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoriteProvider()) { entry in
            FavoriteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ProRodeo Athlete")
        .description("Your favorite athlete's info at a quick glance.")
        .supportedFamilies([.systemLarge])
    }
}

struct FavoriteWidget_Previews: PreviewProvider {
    static var previews: some View {
        let exampleData = BioData(results: [BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 0, payoff: 250000.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 674, eventType: "TD", place: 3, payoff: 1250.00, time: 8.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 25000.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 25000.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 25000.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 25000.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023)], career: [Career(season: 2023, eventType: "TD", earnings: 100000.00, worldTitles: 4, nfrQualified: false, timedStatistics: nil)], rankings: [Ranking(rank: "#1", rankType: "World", eventName: "Tie-down Roping", season: 2023, tourId: nil, circuitId: nil)], earnings: ["2023": [Earning(seasonYear: 2023, earnings: 100000.00, eventType: "TD")]], contestantId: 70406, firstName: "Caleb", lastName: "Smidt", nickName: "Caleb", hometown: "Somewhere, TX", imageUrl: "", featured: false, birthDate: "1994-2-27", age: 31, totalEarnings: 1200987.87, yearEarnings: 100000, worldTitles: 4, nfrQualifications: 7, dateJoined: "2012-1-12", eventTypes: ["TD, TR"], biographyText: "")
        
        
        Group {
//            FavoriteWidgetEntryView(entry: FavoriteWidgetEntry(date: Date(), bio: exampleData))
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            FavoriteWidgetEntryView(entry: FavoriteWidgetEntry(date: Date(), bio: exampleData, event: .td))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
