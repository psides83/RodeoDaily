//
//  WidgetResultsApi.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/8/23.
//

import Foundation
import SwiftUI

class ResultsWidgetApi: ObservableObject {
    
    func getRodeos(event: Events.CodingKeys, _ completionHandler: @escaping (_ rodeo: RodeoData) async -> Void) async {
        
        guard let url = URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/schedule?type=results&page_size=48&index=1&active=true&search_term=&search_type=&tourId=&circuitId=&combine_results=true") else { fatalError("Missing URL") }
        
        do {
            let filteredRodeos = try await PaginatedRodeoLoader.fetchPage(from: url, event: event)

            guard filteredRodeos.count > 0 else {
                return
            }

            guard let featuredRodeo = filteredRodeos.first(where: { rodeo in rodeo.payout > 175000.00 }) else {
                return
            }

            await completionHandler(featuredRodeo)
        } catch {
        }
    }
    
    func loadRodeos(event: Events.CodingKeys, _ completionHandler: @escaping (RodeoResult) async -> Void) async {
        
        await getRodeos(event: event) { rodeo in
            await self.getWinners(rodeoId: rodeo.id, event: event) { result in
                await completionHandler(result)
            }
        }
    }
    
    
    func fetchResults(rodeoId: Int, event: Events.CodingKeys, _ completionHandler: @escaping (Datum, [String: [Round]]) async -> Void) async {
        
        guard let url = URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/results?rodeoid=\(rodeoId)") else { fatalError("Missing URL") }
        
        do {
            let response = try await APIClient.fetch(RodeoResults.self, from: url)

            guard let resultData = ResultsMapper.rodeoAndRounds(from: response, event: event)
            else { return }

            await completionHandler(resultData.rodeo, resultData.rounds)
        } catch {
        }
    }
    
    func getWinners(
        rodeoId: Int,
        event: Events.CodingKeys,
        _ completionHandler: @escaping (RodeoResult) async -> Void
    ) async {
        
        await fetchResults(rodeoId: rodeoId, event: event) { (rodeo, rounds) in
            let result = ResultsMapper.map(rodeoId: rodeoId, rodeo: rodeo, rounds: rounds, event: event)
            await completionHandler(result)
        }
    }
}
