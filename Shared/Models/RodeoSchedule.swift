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
