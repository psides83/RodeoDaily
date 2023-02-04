//
//  BioExtension.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation
import SwiftUI

extension BioData {
    var name: String {
        guard let nick = nickName else { return "\(firstName) \(lastName)" }
        
        return "\(nick) \(lastName)"
    }
    
    var currentRank: String {
        rankings.first(where: { $0.season == Date().yearInt })?.rank ?? "Unranked"
    }
    
    var currentRankEvent: String {
        rankings.first(where: { $0.season == Date().yearInt })?.eventName.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unranked"
    }
    
    var athleteAge: String {
        guard let checkAge = age else { return "unknown" }
        
        return checkAge.string
    }
    
    var worldTitlesCount: String {
        if contestantId == 97915 {
            guard let titles = worldTitles else { return "1 World title" }
            
            return "\(titles) World Titles"
        }
        guard let titles = worldTitles else { return "No World Titles" }
        
        if titles == 1 {
            return "\(titles) World Title"
        } else {
            return "\(titles) World Titles"
        }
    }
    
    var careerEarnings: String {
        guard let earnings = totalEarnings else { return "No Career Earnings" }
        
        return "\(earnings.shortenedCurrency) Career Earnings"
    }
    
    var nfrQuals: String {
        guard let nfrs = nfrQualifications else { return "No NFRs" }
        
        if nfrs == 1 {
            return "\(nfrs) NFR"
        } else {
            return "\(nfrs) NFR's"
        }
    }
    
    var image: some View {
        guard let url = imageUrl else {
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.5)
            }
//            .frame(width: 48, height: 48)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
                
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
        } placeholder: {
            Color.gray.opacity(0.5)
        }
//        .frame(width: 48, height: 48)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
