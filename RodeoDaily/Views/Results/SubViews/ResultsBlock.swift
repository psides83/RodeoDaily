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
    var widgetAthletes: [WidgetAthlete]
    
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
                    
                    if event == .tr {
                        
                        ForEach(teams(from: round)) { team in
                            //
                            
                            TRWinnerCell(team: team, widgetAthletes: widgetAthletes)
                            
                            Divider()
                                .overlay(Color.appTertiary)
                        }
                    } else {
                        ForEach(round.winners) { winner in
                            WinnerCell(event: event.rawValue, winner: winner, widgetAthletes: widgetAthletes)
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
    
    func teams(from round: RoundWinners) -> [Team] {
        var addedTeams = [Int]()
        var teams = [Team]()
        
        round.winners.forEach { winner in
            let isCurrentTeam = addedTeams.filter({ $0 == winner.teamId }).count > 0
            
            let teamArray = round.winners.filter({ $0.teamId == winner.teamId })
            let header = teamArray[0]
            let heeler = teamArray[1]
            
            let team = Team(id: header.teamId, headerId: header.contestantId, headerName: header.name, heelerId: heeler.contestantId, heelerName: heeler.name, roundLabel: header.roundLabel, place: header.placeDisplay, headerHometown: header.hometownDisplay, heelerHometown: heeler.hometownDisplay, headerImageUrl: header.imageUrl, heelerImageUrl: heeler.imageUrl, payoff: header.earnings, time: header.result, round: header.round)
            
            
            if !isCurrentTeam {
                addedTeams.append(winner.teamId)
                teams.append(team)
            }
        }
        
        return teams
    }
}

struct ResultsBlock_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
