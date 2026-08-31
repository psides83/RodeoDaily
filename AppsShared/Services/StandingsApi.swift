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
    @Published private(set) var state: LoadingState<[Position]> = .idle([])

    var standings: [Position] { state.value }
    var loading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }
    
    func getStandings(
        for event: StandingsEvent,
        type: StandingType = .world,
        circuit: Circuit = .columbiaRiver,
        selectedYear: String = Date().yearString
    ) async {
        state = .loading(standings)
        
        do {
            let loadedStandings = try await StandingsService.fetchStandings(
                event: event,
                type: type,
                circuit: circuit,
                selectedYear: selectedYear
            )
            state = .loaded(loadedStandings)
        } catch {
            state = .failed([], message: error.localizedDescription)
        }
    }
}
