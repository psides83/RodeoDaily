//
//  ResultsApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

@MainActor
final class ResultsApi: ObservableObject {
    private let apiUrls = ApiUrls()
    
    @Published var results = RodeoResult(id: 0, city: "", state: "", name: "", rounds: [])
    @Published var loading = true
    
    func fetchResults(
        rodeoId: Int,
        event: Events.CodingKeys,
        _ completionHandler: @escaping (Datum, [String: [Round]]) -> Void
    ) async {
        let url = apiUrls.resultsUrl(for: rodeoId)
        
        do {
            let response = try await APIClient.fetch(RodeoResults.self, from: url)

            guard let resultData = ResultsMapper.rodeoAndRounds(from: response, event: event) else {
                return
            }

            completionHandler(resultData.rodeo, resultData.rounds)
        } catch {
        }
    }
    
    func getWinners(
        rodeoId: Int,
        event: Events.CodingKeys,
        _ completionHandler: @escaping (RodeoResult) -> Void
    ) async {
        await fetchResults(
            rodeoId: rodeoId,
            event: event,
        ) { (rodeo, rounds) in
            let result = ResultsMapper.map(rodeoId: rodeoId, rodeo: rodeo, rounds: rounds, event: event)
            completionHandler(result)
        }
    }
    
    func loadResults(
        rodeoId: Int,
        event: Events.CodingKeys,
        _ completionHandler: @escaping () -> Void
    ) async {
        let url = apiUrls.resultsUrl(for: rodeoId)

        do {
            let response = try await APIClient.fetch(RodeoResults.self, from: url)
            self.results = ResultsMapper.map(rodeoId: rodeoId, response: response, event: event)
                ?? RodeoResult(id: rodeoId, city: "", state: "", name: "", rounds: [])
        } catch {
            self.results = RodeoResult(id: rodeoId, city: "", state: "", name: "", rounds: [])
        }

        completionHandler()
    }
    
    func setLoading() {
        loading = true
    }
    
    func endLoading() {
        loading = false
    }
}
