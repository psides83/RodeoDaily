//
//  WidgetStandingsApi.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/4/23.
//

import Foundation
import SwiftUI

class StandingsWidgetApi: ObservableObject {
    
    func getStandings(event: StandingsEvent, completionHandler: @escaping ([Position]) -> Void) async {
        let now = Date()
        let seasonYear = now.monthInt >= 10 ? now.yearInt + 1 : now.yearInt
        let year = seasonYear.string
        
        var dynamicUrl: URL? {
            if event.isWPRA {
                return nil
            } else {
                return URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/standings?year=\(year)&type=world&id=&event=\(event.rawValue)")
            }
        }

        if event.isWPRA {
            do {
                let standings = try await fetchWpraStandingsFromSupabase(event: event, seasonYear: seasonYear)
                completionHandler(standings)
            } catch {
                print("Error decoding: ", error)
                completionHandler([])
            }
            return
        }

        guard let url = dynamicUrl else {
            completionHandler([])
            return
        }

        do {
            let standings = try await APIService.fetchStandings(from: url).data
            completionHandler(standings)
        } catch {
            print("Error decoding: ", error)
            completionHandler([])
        }
    }

    private func fetchWpraStandingsFromSupabase(event: StandingsEvent, seasonYear: Int) async throws -> [Position] {
        let supabaseConfig = SupabaseConfig()
        let type: StandingType = .world
//        let projectURL = supabaseConfig.projectURL
        
//        var query = "\(projectURL)/rest/v1/standings?select=id,contestant_id,season_year,event,type,circuit_id,place,first_name,last_name,hometown,earnings,points"
//        query += "&season_year=eq.\(seasonYear)"
//        query += "&event=eq.\(event.rawValue)"
//        query += "&type=eq.world"
//        query += "&order=place.asc,earnings.desc"
//
//        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: encoded) else {
//            return []
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
//        request.setValue("Bearer \(SupabaseConfig.publishableKey)", forHTTPHeaderField: "Authorization")
        
        let request = try supabaseConfig.getURL(normalizedType: type.rawValue, seasonYear: seasonYear, event: event, type: type)


        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "<empty>"
            throw NSError(domain: "StandingsWidgetApi", code: statusCode, userInfo: [NSLocalizedDescriptionKey: bodyText])
        }

        let json = try JSONSerialization.jsonObject(with: data)
        guard let rows = json as? [[String: Any]] else { return [] }

        var results: [Position] = []
        results.reserveCapacity(rows.count)

        for row in rows {
            let rowId = intValue(in: row, keys: ["id"])
            let contestantId = optionalIntValue(in: row, keys: ["contestant_id"])
            let positionId = contestantId ?? rowId
//            let hasBio = contestantId != nil
            let place = intValue(in: row, keys: ["place"])
            if positionId <= 0 || place <= 0 { continue }

            let firstName = stringValue(in: row, keys: ["first_name"])
            let lastName = stringValue(in: row, keys: ["last_name"])

            let position = Position(
                id: positionId,
                firstName: firstName.isEmpty ? NSLocalizedString("Unknown", comment: "") : firstName,
                lastName: lastName.isEmpty ? NSLocalizedString("Athlete", comment: "") : lastName,
                event: stringValue(in: row, keys: ["event"]),
                type: stringValue(in: row, keys: ["type"]),
                hometown: optionalStringValue(in: row, keys: ["hometown"]),
                nickName: nil,
                imageUrl: nil,
//                hasBio: hasBio,
                earnings: doubleValue(in: row, keys: ["earnings"]),
                points: doubleValue(in: row, keys: ["points"]),
                place: place,
                standingId: rowId,
                seasonYear: intValue(in: row, keys: ["season_year"]),
                tourId: nil,
                circuitId: optionalIntValue(in: row, keys: ["circuit_id"])
            )

            results.append(position)
        }

        return results
    }

    private func stringValue(in row: [String: Any], keys: [String]) -> String {
        optionalStringValue(in: row, keys: keys) ?? ""
    }

    private func optionalStringValue(in row: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = row[key] as? String {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }
        }
        return nil
    }

    private func intValue(in row: [String: Any], keys: [String]) -> Int {
        for key in keys {
            if let value = row[key] as? Int { return value }
            if let value = row[key] as? Double { return Int(value) }
            if let value = row[key] as? String, let parsed = Int(value) { return parsed }
        }
        return 0
    }

    private func optionalIntValue(in row: [String: Any], keys: [String]) -> Int? {
        for key in keys {
            if let value = row[key] as? Int { return value }
            if let value = row[key] as? Double { return Int(value) }
            if let value = row[key] as? String, let parsed = Int(value) { return parsed }
        }
        return nil
    }

    private func doubleValue(in row: [String: Any], keys: [String]) -> Double {
        for key in keys {
            if let value = row[key] as? Double { return value }
            if let value = row[key] as? Int { return Double(value) }
            if let value = row[key] as? String, let parsed = Double(value) { return parsed }
        }
        return 0
    }
}

