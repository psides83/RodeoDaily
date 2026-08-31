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

    enum CodingKeys: String, CodingKey {
        case error
        case data
    }

    init(error: JSONNull? = nil, data: [Position]) {
        self.error = error
        self.data = data
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           container.contains(.data) {
            error = try container.decodeIfPresent(JSONNull.self, forKey: .error)
            data = try container.decode([Position].self, forKey: .data)
            return
        }

        error = nil
        data = try decoder.singleValueContainer().decode([Position].self)
    }
}

// MARK: - Datum
struct Position: Codable, Identifiable {
    let id: Int
    let firstName, lastName, event, type: String
    let hometown, nickName, imageUrl: String?
    let earnings, points: Double
    let place, standingId, seasonYear: Int
    let tourId, circuitId: Int?
    var contestantId: Int? = nil
    var hasBio: Bool = true

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
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleStandingsKey.self)

        let rowId = try container.decodeFlexibleOptionalInt(forKeys: ["StandingId", "standing_id", "id"])
        let decodedContestantId = try container.decodeFlexibleOptionalInt(forKeys: ["ContestantId", "contestant_id"])
        let contestantId = decodedContestantId ?? rowId ?? 0
        let standingId = rowId ?? contestantId

        id = contestantId
        firstName = try container.decodeFlexibleString(forKeys: ["FirstName", "first_name"])
        lastName = try container.decodeFlexibleString(forKeys: ["LastName", "last_name"])
        event = try container.decodeFlexibleString(forKeys: ["Event", "event", "event_abbrev"])
        type = try container.decodeFlexibleString(forKeys: ["Type", "type", "standing_type"])
        hometown = try container.decodeFlexibleOptionalString(forKeys: ["Hometown", "hometown"])
        nickName = try container.decodeFlexibleOptionalString(forKeys: ["NickName", "nick_name"])
        imageUrl = try container.decodeFlexibleOptionalString(forKeys: AthleteImage.prcaImageUrlKeys)
        earnings = try container.decodeFlexibleDouble(forKeys: ["Earnings", "earnings"])
        points = try container.decodeFlexibleDouble(forKeys: ["Points", "points"])
        place = try container.decodeFlexibleInt(forKeys: ["Place", "place"])
        self.standingId = standingId
        seasonYear = try container.decodeFlexibleInt(forKeys: ["SeasonYear", "season_year"])
        tourId = try container.decodeFlexibleOptionalInt(forKeys: ["TourId", "tour_id"])
        circuitId = try container.decodeFlexibleOptionalInt(forKeys: ["CircuitId", "circuit_id"])
        self.contestantId = decodedContestantId
        hasBio = decodedContestantId != nil
    }
}

private struct FlexibleStandingsKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

private extension KeyedDecodingContainer where Key == FlexibleStandingsKey {
    func decodeFlexibleString(forKeys keys: [String]) throws -> String {
        try decodeFlexibleOptionalString(forKeys: keys) ?? ""
    }

    func decodeFlexibleOptionalString(forKeys keys: [String]) throws -> String? {
        for key in keys {
            guard let codingKey = FlexibleStandingsKey(stringValue: key), contains(codingKey) else { continue }
            if try decodeNil(forKey: codingKey) { return nil }
            if let value = try? decode(String.self, forKey: codingKey) {
                return value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if let value = try? decode(Int.self, forKey: codingKey) {
                return value.string
            }
            if let value = try? decode(Double.self, forKey: codingKey) {
                return value.string
            }
        }
        return nil
    }

    func decodeFlexibleInt(forKeys keys: [String]) throws -> Int {
        if let value = try decodeFlexibleOptionalInt(forKeys: keys) {
            return value
        }

        throw DecodingError.keyNotFound(
            FlexibleStandingsKey(stringValue: keys.first ?? "unknown")!,
            DecodingError.Context(codingPath: codingPath, debugDescription: "No integer value found for keys: \(keys.joined(separator: ", "))")
        )
    }

    func decodeFlexibleOptionalInt(forKeys keys: [String]) throws -> Int? {
        for key in keys {
            guard let codingKey = FlexibleStandingsKey(stringValue: key), contains(codingKey) else { continue }
            if try decodeNil(forKey: codingKey) { return nil }
            if let value = try? decode(Int.self, forKey: codingKey) {
                return value
            }
            if let value = try? decode(Double.self, forKey: codingKey) {
                return Int(value)
            }
            if let value = try? decode(String.self, forKey: codingKey), let parsed = Int(value) {
                return parsed
            }
        }
        return nil
    }

    func decodeFlexibleDouble(forKeys keys: [String]) throws -> Double {
        for key in keys {
            guard let codingKey = FlexibleStandingsKey(stringValue: key), contains(codingKey) else { continue }
            if try decodeNil(forKey: codingKey) { return 0 }
            if let value = try? decode(Double.self, forKey: codingKey) {
                return value
            }
            if let value = try? decode(Int.self, forKey: codingKey) {
                return Double(value)
            }
            if let value = try? decode(String.self, forKey: codingKey), let parsed = Double(value) {
                return parsed
            }
        }
        return 0
    }
}

extension Position {
    var name: String {
        let name = PersonNameComponents(givenName: firstName, familyName: lastName, nickname: nickName)
        
        return name.formatted(.name(style: .medium))
    }
    
    var hometownDisplay: String {
        hometown ?? ""
    }
    
    var image: some View {
        AthleteImageView(preferredImageUrl: imageUrl, cornerRadius: 8)
    }

    var isPlayoffSeriesStanding: Bool {
        tourId == Tour.playoffSeries.id
    }

    var standingsMetricTitle: String {
        isPlayoffSeriesStanding ? NSLocalizedString("Points", comment: "") : NSLocalizedString("Earnings", comment: "")
    }

    var standingsMetricValue: String {
        guard isPlayoffSeriesStanding else {
            return earnings.currency
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: points)) ?? points.string
    }

//    var hasBio: Bool {
//        switch event {
//            case "GB", "LB": return false
//            default: return true
//        }
//    }
}
