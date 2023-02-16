//
//  WinnerCel.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct ResultsBlock: View {
    
    @ObservedObject var resultsApi = ResultsApi()
    
    let rodeo: RodeoData
    let event: Events.CodingKeys
    
    var body: some View {
        let loading = resultsApi.loading
        let roundCount = resultsApi.results.rounds.count
        
        VStack {
            if loading {
                ResultsLoader()
            } else {
                ForEach(resultsApi.results.rounds, id: \.id) { round in
                    HStack {
                        Text(round.roundDisplay(roundCount: roundCount))
                            .foregroundColor(Color.appSecondary)
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.bottom, 4)
                        
                        Spacer()
                    }
                    
                    ForEach(round.winners.indices, id: \.self) { index in
                        if event == .tr {
                            if index % 2 == 0 {
                                TRWinnerCell(winner: round.winners[index], partner: round.winners[index + 1])
                                
                                Divider()
                                    .overlay(Color.appTertiary)
                            }
                        } else {
                            WinnerCell(event: event.rawValue, winner: round.winners[index])
                        }
                    }
                }
            }
        }
        .task {
            await resultsApi.loadResults(rodeoId: rodeo.id, event: event) {
                resultsApi.endLoading()
            }
        }
    }
}

struct ResultsBlock_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
