//
//  PaginatedRodeoLoader.swift
//  RodeoDaily
//
//  Created by Codex on 5/15/26.
//

import Foundation

enum PaginatedRodeoLoader {
    static func fetchPage(
        from url: URL,
        event: Events.CodingKeys? = nil
    ) async throws -> [RodeoData] {
        let page = try await APIClient.fetch(RodeoSchedule.self, from: url).data

        guard let event else {
            return page
        }

        return filter(page, for: event)
    }

    static func mergedPage(
        current rodeos: [RodeoData],
        incoming page: [RodeoData],
        index: Int
    ) -> [RodeoData] {
        index > 1 ? rodeos + page : page
    }

    static func filter(
        _ rodeos: [RodeoData],
        for event: Events.CodingKeys
    ) -> [RodeoData] {
        switch event {
        case .bb:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("bareback") }
        case .sw:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("steer") }
        case .sb:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("saddle") }
        case .td:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("tie-down") }
        case .gb:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("racing") }
        case .br:
            return rodeos.filter {
                $0.htmlUnwrap.localizedCaseInsensitiveContains("bull")
                && $0.htmlUnwrap.localizedCaseInsensitiveContains("riding")
            }
        case .tr:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("team") }
        case .sr:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("steer roping") }
        case .lb:
            return rodeos.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("breakaway") }
        }
    }

    static func uniqueById(_ rodeos: [RodeoData]) -> [RodeoData] {
        Dictionary(grouping: rodeos, by: \.id).compactMap { $0.value.first }
    }
}
