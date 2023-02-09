//
//  RodeoDetailView.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import SwiftUI

struct RodeoDetailView: View {
    
    @ObservedObject var resultsApi = ResultsApi()
    
    let rodeo: RodeoData
    let event: Events.CodingKeys
    
    var body: some View {
//        let loading = resultsApi.loading
        let roundCount = resultsApi.results.rounds.count
        
        VStack {
            //            Text(rodeo.name)
            List{
                ForEach(resultsApi.results.rounds, id: \.id) { round in
                    Section(header: HStack {
                        Text(round.round == "Avg" || round.round == "Finals" || roundCount == 1 ? roundCount == 1 ? "" : "\(round.round)" : "Round \(round.round)")
                            .accentColor(Color.rdGray)
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.bottom, 4)
                        
                        Spacer()
                    }) {
                        
                        ForEach(round.winners.indices, id: \.self) { index in
                            if event == .tr && index % 2 == 0 {
                                TRWinnerCell(winner: round.winners[index], partner: round.winners[index + 1])
                            } else if event != .tr {
                                WinnerCell(winner: round.winners[index])
                            }
                        }
                    }
                }
            }
        }
        .task{
                await resultsApi.loadResults(rodeoId: rodeo.id, event: event) {
                    resultsApi.endLoading()
                }
        }
    }
}

struct RodeoDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        let rodeo = RodeoData(id: 12582, seasonYear: 2023, name: "Fort Worth Stock Show & Rodeo", city: "Fort Worth", state: "TX", startDate: "2023-01-20T00:00:00", endDate: "2023-02-04T00:00:00", payout: 908800, inProgress: true, isActive: true, htmlResults: nil, venueName: "Dickies Arena", circuitId: 7, circuitIds: [7])
        
        RodeoDetailView(rodeo: rodeo, event: .bb)
    }
}
