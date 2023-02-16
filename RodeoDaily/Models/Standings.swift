//
//  Standings.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

// MARK: - Standings
struct Standings: Codable {
    let error: JSONNull?
    let data: [Position]
}

// MARK: - Datum
struct Position: Codable, Identifiable {
    let id: Int
    let firstName, lastName, event, type: String
    let hometown, nickName, imageUrl: String?
    let earnings, points: Double
    let place, standingId, seasonYear: Int
    let tourId, circuitId: Int?

    enum CodingKeys: String, CodingKey {
        case id = "ContestantId"
        case firstName = "FirstName"
        case lastName = "LastName"
        case imageUrl = "SidearmPhotoUrl"
        case earnings = "Earnings"
        case points = "Points"
        case place = "Place"
        case event = "Event"
        case type = "Type"
        case nickName = "NickName"
        case hometown = "Hometown"
        case standingId = "StandingId"
        case seasonYear = "SeasonYear"
        case tourId = "TourId"
        case circuitId = "CircuitId"
    }
}

extension Position {
    var name: String {
        guard nickName != "" else { return "\(firstName) \(lastName)" }
        
        return "\(nickName ?? firstName) \(lastName)"
    }
    
    var image: some View {
        guard let url = imageUrl else {
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
                    .frame(width: 48, height: 48)
                
            } placeholder: {
                Image.noImage.resizable()
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
                
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
                .frame(width: 48, height: 48)
            
        } placeholder: {
            Image.noImage.resizable()
            
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    var hasBio: Bool {
        switch event {
            case "AA", "GB", "LB": return false
            default: return true
        }
    }
}
