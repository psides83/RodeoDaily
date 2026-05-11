//
//  standings-api.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import Foundation
import SwiftUI

@MainActor
final class StandingsApi: ObservableObject {
    private let apiUrls = ApiUrls()
    
    @Published var standings = [Position]()
    @Published var loading = false
    
    func getStandings(
        for event: StandingsEvent,
        type: StandingType = .world,
        circuit: Circuit = .columbiaRiver,
        selectedYear: String = Date().yearString
    ) async {
        loading = true
                
        let url = apiUrls.standingsUrl(
            event: event,
            type: type,
            circuit: circuit,
            selectedYear: selectedYear
        )
        
        do {
            if event == .gb || event == .lb {
                standings = try await WpraSupabaseStandingsService.fetchStandings(
                    event: event,
                    type: type,
                    circuit: circuit,
                    selectedYear: selectedYear
                )
            } else {
                standings = try await APIService.fetchStandings(from: url).data
            }
        } catch {
            standings = []
            print("Error decoding: ", error)
        }

        loading = false
    }
}

private enum WpraSupabaseStandingsService {
    static func fetchStandings(
        event: StandingsEvent,
        type: StandingType,
        circuit: Circuit,
        selectedYear: String
    ) async throws -> [Position] {
        let supabaseConfig = SupabaseConfig()
        let seasonYear = Int(selectedYear) ?? 0
        
        guard seasonYear > 0 else { return [] }

        let typeValue = normalizedType(type.rawValue) ?? "world"
        
        let request = try supabaseConfig.getURL(normalizedType: typeValue, seasonYear: seasonYear, event: event, type: type, circuit: circuit)

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "<empty>"
            throw NSError(domain: "WpraSupabaseStandingsService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: bodyText])
        }

        let json = try JSONSerialization.jsonObject(with: data)
        guard let rows = json as? [[String: Any]] else { return [] }

        return rows
            .compactMap(mapRow(_:))
            .sorted { lhs, rhs in
                if lhs.place == rhs.place {
                    return lhs.earnings > rhs.earnings
                }
                return lhs.place < rhs.place
            }
    }

    private static func mapRow(_ row: [String: Any]) -> Position? {
        let rowId = intValue(in: row, keys: ["id", "Id"])
        let contestantId = optionalIntValue(in: row, keys: ["contestant_id", "ContestantId", "contestantId"])
        let positionId = contestantId ?? rowId
        let hasBio = contestantId != nil
        let firstName = stringValue(in: row, keys: ["first_name", "FirstName", "firstName"])
        let lastName = stringValue(in: row, keys: ["last_name", "LastName", "lastName"])
        let hometown = stringValue(in: row, keys: ["hometown"])
        let event = stringValue(in: row, keys: ["event", "Event", "event_type", "eventType"])
        let place = intValue(in: row, keys: ["place", "Place"])
        let seasonYear = intValue(in: row, keys: ["season_year", "SeasonYear", "seasonYear"])
        let standingType = stringValue(in: row, keys: ["type", "Type", "standing_type", "standingType"])
        let imageUrl = stringValue(in: row, keys: ["photo_url"])

        guard positionId > 0, !event.isEmpty, place > 0, seasonYear > 0 else { return nil }

        let resolvedFirstName = firstName.isEmpty ? NSLocalizedString("Unknown", comment: "") : firstName
        let resolvedLastName = lastName.isEmpty ? NSLocalizedString("Athlete", comment: "") : lastName

        var position = Position(
            id: positionId,
            firstName: resolvedFirstName,
            lastName: resolvedLastName,
            event: event,
            type: standingType,
            hometown: hometown,
            nickName: nil,
            imageUrl: imageUrl,
            earnings: doubleValue(in: row, keys: ["earnings"]),
            points: doubleValue(in: row, keys: ["points"]),
            place: place,
            standingId: rowId,
            seasonYear: seasonYear,
            tourId: nil,
            circuitId: optionalIntValue(in: row, keys: ["circuit_id"]),
        )
        
        position.contestantId = contestantId
        position.hasBio = hasBio
        
        return position
    }

    private static func normalizedType(_ value: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleaned.isEmpty else { return nil }
        if cleaned.contains("world") { return "world" }
        if cleaned.contains("circuit") { return "circuit" }
        if cleaned.contains("rookie") { return "rookie" }
        if cleaned.contains("permit") { return "permit" }
        if cleaned.contains("xtremebull") || cleaned.contains("xbull") { return "xtremebulls" }
        if cleaned.contains("xtremebronc") || cleaned.contains("xbronc") { return "xtremebroncs" }
        if cleaned.contains("legacy") { return "legacysteerroping" }
        return cleaned.replacingOccurrences(of: " ", with: "")
    }

    private static func stringValue(in row: [String: Any], keys: [String]) -> String {
        optionalStringValue(in: row, keys: keys) ?? ""
    }

    private static func optionalStringValue(in row: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = row[key] as? String {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }
        }
        return nil
    }

    private static func intValue(in row: [String: Any], keys: [String]) -> Int {
        for key in keys {
            if let value = row[key] as? Int { return value }
            if let value = row[key] as? Double { return Int(value) }
            if let value = row[key] as? String, let parsed = Int(value) { return parsed }
        }
        return 0
    }

    private static func optionalIntValue(in row: [String: Any], keys: [String]) -> Int? {
        for key in keys {
            if let value = row[key] as? Int { return value }
            if let value = row[key] as? Double { return Int(value) }
            if let value = row[key] as? String, let parsed = Int(value) { return parsed }
        }
        return nil
    }

    private static func doubleValue(in row: [String: Any], keys: [String]) -> Double {
        for key in keys {
            if let value = row[key] as? Double { return value }
            if let value = row[key] as? Int { return Double(value) }
            if let value = row[key] as? String, let parsed = Double(value) { return parsed }
        }
        return 0
    }
}
