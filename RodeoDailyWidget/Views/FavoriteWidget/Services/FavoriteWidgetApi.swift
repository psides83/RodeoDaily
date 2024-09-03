//
//  ContestantWidget.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import Foundation

class FavoriteWidgetApi: ObservableObject {
    
    func loadBio(for athleteId: Int, completionHandler: @escaping (BioData) async -> Void) async {
        
        guard let url = URL(string:
                                "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/athlete?id=\(athleteId)"
        ) else { fatalError("Missing URL") }
        
        do {
            let bio = try await APIService.fetchBio(from: url).data
            await completionHandler(bio)
        } catch {
            print("Error decoding: ", error)
        }
    }
}
