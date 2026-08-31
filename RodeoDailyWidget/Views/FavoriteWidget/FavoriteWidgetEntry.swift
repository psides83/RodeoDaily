//
//  FavoriteWidgetEntry.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import Foundation
import WidgetKit

struct FavoriteWidgetEntry: TimelineEntry {
    let date: Date
    let bio: BioData
    let event: String
    let athleteId: Int?

    var athleteBioURL: URL? {
        guard let athleteId, athleteId > 0 else { return nil }

        var components = URLComponents()
        components.scheme = "rodeodaily"
        components.host = "athlete"
        components.queryItems = [
            URLQueryItem(name: "id", value: athleteId.string),
            URLQueryItem(name: "event", value: event)
        ]
        return components.url
    }
}
