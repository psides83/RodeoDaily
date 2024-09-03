//
//  FavoriteSampleData.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import Foundation

struct WidgetSampleData {
    var favoriteSampleData: BioData {
        let bioResult: BioResult = BioResult(
            rodeoId: 23,
            rodeoName: "Fort Worth",
            city: "Fort Worth",
            state: "TX",
            startDate: "2020-01-30T00:00:00",
            endDate: "2020-02-10T00:00:00",
            rodeoResultId: 833,
            eventType: "TD",
            place: 0,
            payoff: 250000.00,
            time: 7.8,
            score: 0.0,
            round: "1",
            stockId: 0,
            seasonYear: 2023
        )
        
        return BioData(
            results: [
                bioResult,
                bioResult,
                bioResult,
                bioResult,
                bioResult,
                bioResult,
                bioResult
            ],
            career: [
                Career(
                    season: 2023,
                    eventType: "TD",
                    earnings: 100000.00,
                    worldTitles: 4,
                    nfrQualified: false,
                    timedStatistics: nil
                )
            ],
            rankings: [
                Ranking(
                    rank: "#1",
                    rankType: "World",
                    eventName: "Tie-down Roping",
                    season: 2023,
                    tourId: nil,
                    circuitId: nil
                )
            ],
            earnings: [
                "2023": [
                    Earning(seasonYear: 2023, earnings: 100000.00, eventType: "TD")
                ]
            ],
            contestantId: 70406,
            firstName: "Caleb",
            lastName: "Smidt",
            nickName: "Caleb",
            hometown: "Somewhere, TX",
            imageUrl: "",
            featured: false,
            birthDate: "1994-2-27",
            age: 31,
            totalEarnings: 1200987.87,
            yearEarnings: 100000,
            worldTitles: 4,
            nfrQualifications: 7,
            dateJoined: "2012-1-12",
            eventTypes: ["TD, TR"],
            biographyText: ""
        )
    }
    
    var standingsSampleData: [Position] {
        let position = Position(
            id: 96898,
            firstName: "Stetson", 
            lastName: "Wright",
            event: "AA",
            type: "world",
            hometown: "Milford, UT",
            nickName: "Stetson",
            imageUrl: "/images/2023/1/10/01_Stetson_Wright_2022_NFR_SB_.png",
            earnings: 42626.6,
            points: 42626.6,
            place: 1,
            standingId: 291301,
            seasonYear: 2023,
            tourId: nil,
            circuitId: nil
        )
        
        return [
            position,
            position,
            position,
            position,
            position,
            position
        ]
    }
}
