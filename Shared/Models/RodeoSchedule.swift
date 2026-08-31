//
//  RodeoSchedule.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import CoreLocation

// MARK: - RodeoSchedule
struct RodeoSchedule: Codable {
    let error: JSONNull?
    let data: [RodeoData]
}

// MARK: - Datum
struct RodeoData: Identifiable, Codable {
    let id, seasonYear, rodeoNumber: Int
    let name, city, state, startDate, endDate: String
    let payout: Double
    let latitude, longitude: Double?
    let inProgress, isActive, hasDaysheets: Bool
    let daysheets: Int
    let htmlResults, websiteUrl: String?
    let venueName: String
    let circuitId: Int
    let circuitIds, tourIds: [Int]

    enum CodingKeys: String, CodingKey {
        case id = "RodeoId"
        case rodeoNumber = "RodeoNumber"
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
        case websiteUrl = "WebsiteUrl"
        case venueName = "VenueName"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case circuitId = "CircuitId"
        case circuitIds = "CircuitIds"
        case hasDaysheets = "HasDaysheets"
        case daysheets = "Daysheets"
        case tourIds = "TourIds"
    }
    
    init(from decoder: Decoder) throws {
        let dynamicContainer = try decoder.container(keyedBy: FlexibleCodingKey.self)
        
        id = Self.decodeInt(from: dynamicContainer, keys: ["RodeoId", "rodeo_id"]) ?? 0
        seasonYear = Self.decodeInt(from: dynamicContainer, keys: ["SeasonYear", "season_year"]) ?? 0
        rodeoNumber = Self.decodeInt(from: dynamicContainer, keys: ["RodeoNumber", "rodeo_number"]) ?? 0
        
        name = Self.decodeString(from: dynamicContainer, keys: ["Name", "name"]) ?? ""
        city = Self.decodeString(from: dynamicContainer, keys: ["City", "city"]) ?? ""
        state = Self.decodeString(from: dynamicContainer, keys: ["StateAbbrv", "state_abbrv"]) ?? ""
        startDate = Self.decodeString(from: dynamicContainer, keys: ["StartDate", "start_date"]) ?? ""
        endDate = Self.decodeString(from: dynamicContainer, keys: ["EndDate", "end_date"]) ?? ""
        
        payout = Self.decodeDouble(from: dynamicContainer, keys: ["Payout", "payout"]) ?? 0
        
        inProgress = Self.decodeBool(from: dynamicContainer, keys: ["InProgress", "in_progress"]) ?? false
        isActive = Self.decodeBool(from: dynamicContainer, keys: ["IsActive", "is_active"]) ?? false
        hasDaysheets = Self.decodeBool(from: dynamicContainer, keys: ["HasDaysheets", "has_daysheets"]) ?? false
        daysheets = Self.decodeInt(from: dynamicContainer, keys: ["Daysheets", "daysheets"]) ?? 0
        websiteUrl = Self.decodeString(from: dynamicContainer, keys: ["WebsiteUrl", "website_url"])
        tourIds = Self.decodeIntArray(from: dynamicContainer, keys: ["TourIds", "tour_ids"]) ?? []
        
        htmlResults = Self.decodeString(from: dynamicContainer, keys: ["ApResults", "ap_results"])
        venueName = Self.decodeString(from: dynamicContainer, keys: ["VenueName", "venue_name"]) ?? ""
        latitude = Self.decodeCoordinateValue(
            from: dynamicContainer,
            keys: ["Latitude", "latitude", "lat", "VenueLatitude", "VenueLat", "venue_latitude"]
        )
        longitude = Self.decodeCoordinateValue(
            from: dynamicContainer,
            keys: ["Longitude", "longitude", "lng", "lon", "VenueLongitude", "VenueLng", "VenueLon", "venue_longitude"]
        )
        circuitId = Self.decodeInt(from: dynamicContainer, keys: ["CircuitId", "circuit_id"]) ?? 0
        circuitIds = Self.decodeIntArray(from: dynamicContainer, keys: ["CircuitIds", "circuit_ids"]) ?? []
    }

    private static func decodeCoordinateValue(
        from container: KeyedDecodingContainer<FlexibleCodingKey>,
        keys: [String]
    ) -> Double? {
        decodeDouble(from: container, keys: keys)
    }

    private static func decodeString(
        from container: KeyedDecodingContainer<FlexibleCodingKey>,
        keys: [String]
    ) -> String? {
        for key in keys {
            let codingKey = FlexibleCodingKey(stringValue: key)
            if let value = try? container.decodeIfPresent(String.self, forKey: codingKey) {
                return value
            }
        }
        return nil
    }

    private static func decodeInt(
        from container: KeyedDecodingContainer<FlexibleCodingKey>,
        keys: [String]
    ) -> Int? {
        for key in keys {
            let codingKey = FlexibleCodingKey(stringValue: key)
            if let value = try? container.decodeIfPresent(Int.self, forKey: codingKey) {
                return value
            }
            if let value = try? container.decodeIfPresent(Double.self, forKey: codingKey) {
                return Int(value)
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: codingKey),
               let decoded = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return decoded
            }
        }
        return nil
    }

    private static func decodeDouble(
        from container: KeyedDecodingContainer<FlexibleCodingKey>,
        keys: [String]
    ) -> Double? {
        for key in keys {
            let codingKey = FlexibleCodingKey(stringValue: key)
            if let value = try? container.decodeIfPresent(Double.self, forKey: codingKey) {
                return value
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: codingKey) {
                return Double(value)
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: codingKey),
               let decoded = Double(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return decoded
            }
        }
        return nil
    }

    private static func decodeBool(
        from container: KeyedDecodingContainer<FlexibleCodingKey>,
        keys: [String]
    ) -> Bool? {
        for key in keys {
            let codingKey = FlexibleCodingKey(stringValue: key)
            if let value = try? container.decodeIfPresent(Bool.self, forKey: codingKey) {
                return value
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: codingKey) {
                return value != 0
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: codingKey) {
                let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if ["true", "1", "yes"].contains(normalized) {
                    return true
                }
                if ["false", "0", "no"].contains(normalized) {
                    return false
                }
            }
        }
        return nil
    }

    private static func decodeIntArray(
        from container: KeyedDecodingContainer<FlexibleCodingKey>,
        keys: [String]
    ) -> [Int]? {
        for key in keys {
            let codingKey = FlexibleCodingKey(stringValue: key)
            if let value = try? container.decodeIfPresent([Int].self, forKey: codingKey) {
                return value
            }
            if let value = try? container.decodeIfPresent([String].self, forKey: codingKey) {
                return value.compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            }
        }
        return nil
    }
}

extension RodeoData {
    var location: String {
        "\(city), \(state)"
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude,
              let longitude,
              (-90...90).contains(latitude),
              (-180...180).contains(longitude),
              latitude != 0,
              longitude != 0 else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var htmlUnwrap: String {
        guard let html = htmlResults else {
            return "no html results"
        }
        
        return html
    }

    var primaryCircuitTitle: String {
        Circuit.allCases.first(where: { $0.id == circuitId })?.title ?? "Circuit \(circuitId)"
    }

    var circuitTitles: [String] {
        let ids = Set(([circuitId] + circuitIds).filter { $0 > 0 })
        let mapped = ids.map { id in
            Circuit.allCases.first(where: { $0.id == id })?.title ?? "Circuit \(id)"
        }
        return mapped.sorted()
    }

    var tourTitles: [String] {
        let ids = Set(tourIds.filter { $0 > 0 })
        let mapped = ids.compactMap { id -> String? in
            guard let tour = Tour.allCases.first(where: { $0.id == id }) else { return nil }
            return tour == .none ? nil : tour.title
        }
        return mapped.sorted()
    }
}

private struct FlexibleCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}
