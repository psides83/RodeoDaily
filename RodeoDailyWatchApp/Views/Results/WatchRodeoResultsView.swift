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
        let roundCount = resultsApi.results.rounds.count
        
        Group {
            if resultsApi.loading {
                WatchLogoLoader()
            } else {
                VStack(alignment: .leading) {
                    Text(rodeoName)
                        .font(.headline)
                    
                    List {
                        ForEach(resultsApi.results.rounds) { round in
                            Section(header: Text(round.roundDisplay(roundCount: roundCount))) {
                                ForEach(round.winners.indices, id: \.self) { index in
                                    if event == .tr {
                                        if index % 2 == 0 {
                                            WatchResultsTRCellView(index: index, winners: round.winners)
                                        }
                                    } else {
                                        WatchResultsCellView(winner: round.winners[index])
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Results")
                }
            }
        }
        .task {
            await resultsApi.loadResults(rodeoId: rodeoId, event: event) {
                resultsApi.endLoading()
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
