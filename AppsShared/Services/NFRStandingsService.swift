//
//  NFRStandingsService.swift
//  RodeoDaily
//

import Foundation

enum NFRStandingsService {
    static func fetchStandings(event: StandingsEvent) async throws -> [NFRContestant] {
        var components = URLComponents(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/nfr.ashx/standings")
        components?.queryItems = [
            URLQueryItem(name: "event", value: event.withTeamRopingConversion)
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let response = try await APIClient.fetch(NFRStandingsResponse.self, from: url)
        return response.data.data
    }
}
