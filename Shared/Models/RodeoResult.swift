//
//  RodeoResult.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

struct RodeoResult: Identifiable, Hashable {
    let id: Int
    let city, state, name: String
    let rounds: [RoundWinners]
}

extension RodeoResult {
    var location: String {
        return "\(city), \(state)"
    }
}

struct RoundWinners: Identifiable, Hashable {
    let id: Int
    let round: String
    let winners: [Winner]
    
    func roundDisplay(roundCount: Int) -> String {
        guard roundCount != 1 else { return "" }
        
        switch round {
            case "Avg", "Finals": return round
            default: return "Round \(round)"
        }
    }
}

struct Winner: Identifiable, Hashable {    
    let id: Int
    let contestantId: Int
    let roundLabel, name: String
    let hometown, imageUrl: String?
    let payoff, time, score: Double
    let place, round, teamId, numberScores: Int
    
    var hometownDisplay: String {
        hometown ?? ""
    }
    
    var image: some View {
        guard let url = imageUrl else {
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
            } placeholder: {
                Image.noImage.resizable()
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
                
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
        } placeholder: {
            Image.noImage.resizable()
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var placeDisplay: String {
        if place == 9999 {
            return " -"
        } else {
            return place.string
        }
    }
    
    var result: String {
        if self.time != 0.0 {
            return self.time.string
        } else if self.score != 0.0 {
            return self.score.string
        } else {
            return ""
        }
    }

    var earnings: String {
        payoff == 0 ? "" : payoff.currency
    }
    
    var earningsABS: String {
        payoff == 0 ? "" : payoff.currencyABS
    }
}
