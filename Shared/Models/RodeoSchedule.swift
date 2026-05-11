//
//  RodeoSchedule.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation

// MARK: - RodeoSchedule
struct RodeoSchedule: Codable {
    let error: JSONNull?
    let data: [RodeoData]
}

// MARK: - Datum
struct RodeoData: Identifiable, Codable {
    let id, seasonYear: Int
    let name, city, state, startDate, endDate: String
    let payout: Double
    let inProgress, isActive: Bool
    let htmlResults: String?
    let venueName: String
    let circuitId: Int
    let circuitIds: [Int]

    enum CodingKeys: String, CodingKey {
        case id = "RodeoId"
        case seasonYear = "SeasonYear"
        case name = "Name"
        case city = "City"
        case state = "StateAbbrv"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case payout = "Payout"
        case inProgress = "InProgress"
        case isActive = "IsActive"
        case htmlResults = "ApResults"
        case venueName = "VenueName"
        case circuitId = "CircuitId"
        case circuitIds = "CircuitIds"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        seasonYear = try container.decodeIfPresent(Int.self, forKey: .seasonYear) ?? 0
        
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate) ?? ""
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate) ?? ""
        
        if let decodedPayout = try container.decodeIfPresent(Double.self, forKey: .payout) {
            payout = decodedPayout
        } else if let decodedPayoutInt = try container.decodeIfPresent(Int.self, forKey: .payout) {
            payout = Double(decodedPayoutInt)
        } else if let decodedPayoutString = try container.decodeIfPresent(String.self, forKey: .payout) {
            payout = Double(decodedPayoutString) ?? 0
        } else {
            payout = 0
        }
        
        inProgress = try container.decodeIfPresent(Bool.self, forKey: .inProgress) ?? false
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
        
        htmlResults = try container.decodeIfPresent(String.self, forKey: .htmlResults)
        venueName = try container.decodeIfPresent(String.self, forKey: .venueName) ?? ""
        circuitId = try container.decodeIfPresent(Int.self, forKey: .circuitId) ?? 0
        circuitIds = try container.decodeIfPresent([Int].self, forKey: .circuitIds) ?? []
    }
}

extension RodeoData {
    var location: String {
        "\(city), \(state)"
    }
    
    var htmlUnwrap: String {
        guard let html = htmlResults else {
            return "no html results"
        }
        
        return html
    }
}
