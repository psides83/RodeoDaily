//
//  ContestantWidget.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import Foundation

class FavoriteWidgetApi: ObservableObject {
    
    func loadBio(for athleteId: Int, completionHandler: @escaping (BioData) async -> Void) async {
        guard var components = URLComponents(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/athlete") else {
            print("[FavoriteWidget] Unable to build athlete URL for ID \(athleteId)")
            return
        }

        components.queryItems = [
            URLQueryItem(name: "id", value: athleteId.string),
            URLQueryItem(name: "_rdWidgetRefresh", value: String(Int(Date().timeIntervalSince1970 / 3600)))
        ]

        guard let url = components.url else {
            print("[FavoriteWidget] Unable to build athlete URL for ID \(athleteId)")
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 15
        
        do {
            let bio = try await APIClient.fetch(Bio.self, for: request).data
            await completionHandler(bio)
        } catch {
            print("[FavoriteWidget] Failed loading athlete ID \(athleteId): \(error.localizedDescription)")
        }
    }
}
