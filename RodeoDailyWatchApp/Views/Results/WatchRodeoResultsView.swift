//
//  WatchRodeoResultsView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchRodeoResultsView: View {
    // MARK: - Properties
    @StateObject var resultsApi = ResultsApi()
    
    let rodeoId: Int
    let rodeoName: String
    let event: Events.CodingKeys
    
    // MARK: - Body
    var body: some View {
        content
            .navigationTitle("Results")
            .task {
                await resultsApi.loadResults(rodeoId: rodeoId, event: event) {
                    resultsApi.endLoading()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        let roundCount = resultsApi.results.rounds.count

        if resultsApi.loading {
            WatchLogoLoader()
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text(rodeoName)
                    .font(.headline)
                    .lineLimit(2)

                if resultsApi.results.rounds.isEmpty {
                    ContentUnavailableView {
                        Label("No Results", systemImage: "list.number")
                    } description: {
                        Text("Results are unavailable for this rodeo.")
                    }
                } else {
                    List {
                        ForEach(resultsApi.results.rounds) { round in
                            Section(header: Text(round.roundDisplay(roundCount: roundCount))) {
                                if event == .tr {
                                    ForEach(
                                        Array(stride(from: 0, to: round.winners.count, by: 2)),
                                        id: \.self
                                    ) { index in
                                        WatchResultsTRCellView(index: index, winners: round.winners, event: event)
                                    }
                                } else {
                                    ForEach(round.winners, id: \.id) { winner in
                                        WatchResultsCellView(winner: winner, event: event)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}

struct WatchRodeoResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchRodeoResultsView(rodeoId: 12867, rodeoName: "", event: .tr)
        }
    }
}
