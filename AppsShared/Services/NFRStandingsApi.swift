//
//  NFRStandingsApi.swift
//  RodeoDaily
//

import Foundation

@MainActor
final class NFRStandingsApi: ObservableObject {
    @Published private(set) var state: LoadingState<[NFRContestant]> = .idle([])

    var standings: [NFRContestant] { state.value }
    var loading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }

    func load(event: StandingsEvent) async {
        state = .loading(standings)

        do {
            let loadedStandings = try await NFRStandingsService.fetchStandings(event: event)
            state = .loaded(loadedStandings)
        } catch {
            state = .failed([], message: error.localizedDescription)
        }
    }
}
