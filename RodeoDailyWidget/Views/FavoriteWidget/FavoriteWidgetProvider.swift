//
//  FAvoriteWidgetProvider.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import SwiftUI
import WidgetKit

struct FavoriteProvider: TimelineProvider {
    public typealias Entry = FavoriteWidgetEntry
    
    let sampleData = WidgetSampleData().favoriteSampleData

    func placeholder(in context: Context) -> FavoriteWidgetEntry {
        Entry(date: Date(), bio: sampleData, event: .td)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        Task {
            
            @AppStorage("favoriteAthlete", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthlete: FavoriteAthlete? = nil
                        
            await FavoriteWidgetApi().loadBio(for: favoriteAthlete?.id ?? 97915) { bio in
                let entry = Entry(date: Date(), bio: bio, event: favoriteAthlete?.event ?? .td)
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            
            @AppStorage("favoriteAthlete", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthlete: FavoriteAthlete? = nil
            
            await FavoriteWidgetApi().loadBio(for: favoriteAthlete?.id ?? 97915) { bio in
                let entry = Entry(date: Date(), bio: bio, event: favoriteAthlete?.event ?? .td)
                
                print(bio)
                
                let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 12)))
                completion(timeline)
            }
        }
    }
    
//    let exampleData = BioData(results: [BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 674, eventType: "TD", place: 3, payoff: 1250.00, time: 8.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023), BioResult(rodeoId: 23, rodeoName: "Fort Worth", city: "Fort Worth", state: "TX", startDate: "2020-01-30T00:00:00", endDate: "2020-02-10T00:00:00", rodeoResultId: 833, eventType: "TD", place: 1, payoff: 2500.00, time: 7.8, score: 0.0, round: "1", stockId: 0, seasonYear: 2023)], career: [Career(season: 2023, eventType: "TD", earnings: 100000.00, worldTitles: 4, nfrQualified: false, timedStatistics: nil)], rankings: [Ranking(rank: "#1", rankType: "World", eventName: "Tie-down Roping", season: 2023, tourId: nil, circuitId: nil)], earnings: ["2023": [Earning(seasonYear: 2023, earnings: 100000.00, eventType: "TD")]], contestantId: 70406, firstName: "Caleb", lastName: "Smidt", nickName: "Caleb", hometown: "Somewhere, TX", imageUrl: "", featured: false, birthDate: "1994-2-27", age: 31, totalEarnings: 1200987.87, yearEarnings: 100000, worldTitles: 4, nfrQualifications: 7, dateJoined: "2012-1-12", eventTypes: ["TD, TR"], biographyText: "")
}
