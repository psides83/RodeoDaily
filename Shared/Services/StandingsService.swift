//
//  StandingsService.swift
//  RodeoDaily
//
//  Created by Codex on 5/15/26.
//

import Foundation

enum StandingsService {
    static func fetchStandings(
        event: StandingsEvent,
        type: StandingType = .world,
        circuit: Circuit = .columbiaRiver,
        selectedYear: String = Date().yearString
    ) async throws -> [Position] {
        if event.isWPRA {
            return try await fetchStandings(
                from: wpraRequest(
                    event: event,
                    type: type,
                    circuit: circuit,
                    selectedYear: selectedYear
                )
            )
        }

        return try await fetchStandings(
            from: legacyRequest(
                event: event,
                type: type,
                circuit: circuit,
                selectedYear: selectedYear
            )
        )
    }

    static func defaultWidgetSeasonYear(for date: Date = Date()) -> String {
        let seasonYear = date.monthInt >= 10 ? date.yearInt + 1 : date.yearInt
        return seasonYear.string
    }

    private static func wpraRequest(
        event: StandingsEvent,
        type: StandingType,
        circuit: Circuit,
        selectedYear: String
    ) throws -> URLRequest {
        guard let seasonYear = Int(selectedYear), seasonYear > 0 else {
            throw URLError(.badURL)
        }

        let standingsServiceConfig = StandingsServiceConfig()
        return try standingsServiceConfig.getWpraUrl(
            normalizedType: normalizedType(type.rawValue),
            seasonYear: seasonYear,
            event: event,
            type: type,
            circuit: circuit
        )
    }

    private static func legacyRequest(
        event: StandingsEvent,
        type: StandingType,
        circuit: Circuit,
        selectedYear: String
    ) throws -> URLRequest {
        let query = standingsQuery(event: event, type: type, circuit: circuit, selectedYear: selectedYear)
        let urlFilters = "standings?year=\(selectedYear)&type=\(query.legacyType)&id=\(query.legacyId)&event=\(query.event.rawValue)"

        guard let url = URL(string: "\(legacyBaseUrl)\(urlFilters)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        return request
    }

    private static func standingsQuery(
        event: StandingsEvent,
        type: StandingType,
        circuit: Circuit,
        selectedYear: String
    ) -> StandingsQuery {
        let isTour = type == .xBulls || type == .xBroncs || type == .legacySteerRoping || type == .playoff
        let isSingleEventTour = type == .xBulls || type == .xBroncs || type == .legacySteerRoping
        let finalType = isTour ? "tour" : type.rawValue
        let finalEvent: StandingsEvent = isSingleEventTour ? .aa : event

        let legacyId: String
        switch type {
        case .circuit:
            let circuitId = circuit.id.string
            legacyId = circuitId
        case .xBulls:
            let tourId = Tour.xBulls.id.string
            legacyId = tourId
        case .xBroncs:
            let tourId = Tour.xBroncs.id.string
            legacyId = tourId
        case .legacySteerRoping:
            let tourId = Tour.legacySteerRoping.id.string
            legacyId = tourId
        case .playoff:
            let tourId = Tour.playoffSeries.id.string
            legacyId = tourId
        default:
            legacyId = ""
        }

        return StandingsQuery(
            event: finalEvent,
            legacyType: finalType,
            legacyId: legacyId
        )
    }

    private static func fetchStandings(from request: URLRequest) async throws -> [Position] {
        return try await APIClient
            .fetch(Standings.self, for: request)
            .data
            .sorted { lhs, rhs in
                if lhs.place == rhs.place {
                    return lhs.earnings > rhs.earnings
                }
                return lhs.place < rhs.place
            }
    }

    private static func normalizedType(_ value: String) -> String {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleaned.isEmpty else { return "world" }
        if cleaned.contains("world") { return "world" }
        if cleaned.contains("circuit") { return "circuit" }
        if cleaned.contains("rookie") { return "rookie" }
        if cleaned.contains("permit") { return "permit" }
        if cleaned.contains("xtremebull") || cleaned.contains("xbull") { return "xtremebulls" }
        if cleaned.contains("xtremebronc") || cleaned.contains("xbronc") { return "xtremebroncs" }
        if cleaned.contains("legacy") { return "legacysteerroping" }
        if cleaned.contains("playoff") { return "playoffseries" }
        return cleaned.replacingOccurrences(of: " ", with: "")
    }

    private static let legacyBaseUrl = "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/"
}

private struct StandingsQuery {
    let event: StandingsEvent
    let legacyType: String
    let legacyId: String
}
