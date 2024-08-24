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
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                guard let data = data else {
                    print("no data")
                    return
                }
                
                Task {
                    
                    do {
                        let decodedItems = try JSONDecoder().decode(RodeoSchedule.self, from: data)
                        
                        var filteredRodeos: [RodeoData] = []
                        
                        switch event {
                        case .bb:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("bareback") })
                        case .sw:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("steer") })
                        case .sb:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("saddle") })
                        case .td:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("tie-down") })
                        case .gb:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("racing") })
                        case .br:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("bull") && $0.htmlUnwrap.localizedCaseInsensitiveContains("riding")})
                        case .tr:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("team") })
                        case .sr:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("steer roping") })
                        case .lb:
                            filteredRodeos = decodedItems.data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("breakaway") })
                        }
                        
                        guard filteredRodeos.count > 0 else {
                            print("no rodeos")
                            return
                        }
                        
                        print(filteredRodeos.map {rodeo in rodeo.name})
                        
                        
                        //                        self.rodeo = filteredRodeos.filter({ rodeo in rodeo.payout > 175000.00})[0]
                        
                        await completionHandler(filteredRodeos.filter({ rodeo in rodeo.payout > 175000.00})[0])
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func loadRodeos(event: Events.CodingKeys, _ completionHandler: @escaping (RodeoResult) async -> Void) async {
        
        await getRodeos(event: event) { rodeo in
            
            print(rodeo)
            
            await self.getWinners(rodeoId: rodeo.id, event: event) { result in
                await completionHandler(result)
            }
        }
    }
    
    
    func fetchResults(rodeoId: Int, event: Events.CodingKeys, _ completionHandler: @escaping (Datum, [String: [Round]]) async -> Void) async {
        
        guard let url = URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/results?rodeoid=\(rodeoId)") else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                
                Task {
                    
                    do {
                        
                        let decodedItems = try JSONDecoder().decode(RodeoResults.self, from: data)
                        
                        guard decodedItems.data != nil else { return }
                        guard decodedItems.data![0].events != nil else { return }
                        
                        switch event {
                        case .bb:
                            guard decodedItems.data![0].events?.bb != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.bb!)!)
                        case .sw:
                            guard decodedItems.data![0].events?.sw != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.sw!)!)
                        case .sb:
                            guard decodedItems.data![0].events?.sb != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.sb!)!)
                        case .td:
                            guard decodedItems.data![0].events?.td != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.td!)!)
                        case .gb:
                            guard decodedItems.data![0].events?.gb != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.gb!)!)
                        case .br:
                            guard decodedItems.data![0].events?.br != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.br!)!)
                        case .tr:
                            guard decodedItems.data![0].events?.tr != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.tr!)!)
                        case .lb:
                            guard decodedItems.data![0].events?.lb != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.lb!)!)
                        case .sr:
                            guard decodedItems.data![0].events?.sr != nil else { return }
                            await completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.sr!)!)
                        }
                        
                        
                        
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func getWinners(
        rodeoId: Int,
        event: Events.CodingKeys,
        _ completionHandler: @escaping (RodeoResult) async -> Void
    ) async {
        
        await fetchResults(rodeoId: rodeoId, event: event) { (rodeo, rounds) in
            
            let winners = rounds.map { round in
                
                let id = round.key
                
                let roundWinners = round.value
                    .filter({ $0.payoff != 0 })
                    .sorted(by: { $0.payoff > $1.payoff })
                    .map { winner in
                        let contestant = winner.contestant[0]
                        let winnerId = "\(id)\(contestant.id)"
                        let contestantName = contestant.nickName != "" ? "\(contestant.nickName ?? "") \(contestant.lastName)" : "\(contestant.firstName) \(contestant.lastName)"
                        
                        return Winner(
                            id: winnerId.int,
                            contestantId: contestant.id,
                            roundLabel: winner.goRoundLabel,
                            name: contestantName,
                            hometown: contestant.hometown,
                            imageUrl: contestant.imageUrl,
                            payoff: winner.payoff,
                            time: winner.time,
                            score: winner.score,
                            place: winner.place,
                            round: winner.goRound,
                            teamId: 0,
                            numberScores: winner.numberScores ?? 0
                        )
                    }
                
                guard roundWinners.count != 0 else {
                    let currentRound = round.value.sorted(by: { $0.numberScores ?? 0 > $1.numberScores ?? 0 })[0].numberScores
                    
                    if id.int < 555 {
                        let leaders = round.value
                            .filter({ $0.time != 0 || $0.score != 0 })
                            .sorted(by: { $0.time < $1.time })
                            .sorted(by: { $0.score > $1.score })
                            .prefix(10)
                            .enumerated()
                            .map { (index, winner) in
                                let contestant = winner.contestant[0]
                                let winnerId = "\(id)\(contestant.id)"
                                
                                return Winner(
                                    id: winnerId.int,
                                    contestantId: contestant.id,
                                    roundLabel: winner.goRoundLabel,
                                    name: contestant.name,
                                    hometown: contestant.hometown,
                                    imageUrl: contestant.imageUrl,
                                    payoff: winner.payoff,
                                    time: winner.time,
                                    score: winner.score,
                                    place: winner.place == 0 ? index + 1 : winner.place,
                                    round: winner.goRound,
                                    teamId: 0,
                                    numberScores: winner.numberScores ?? 0
                                )
                            }
                        
                        return RoundWinners(
                            id: id.int,
                            round: leaders[0].roundLabel,
                            winners: leaders
                        )
                    } else {
                        let leaders = round.value
                            .filter({ $0.time != 0 || $0.score != 0 })
                            .filter({ $0.numberScores == currentRound })
                            .sorted(by: { $0.time < $1.time })
                            .sorted(by: { $0.score > $1.score })
                            .prefix(10)
                            .enumerated()
                            .map { (index, winner) in
                                let contestant = winner.contestant[0]
                                let winnerId = "\(id)\(contestant.id)"
                                
                                return Winner(
                                    id: winnerId.int,
                                    contestantId: contestant.id,
                                    roundLabel: winner.goRoundLabel,
                                    name: contestant.name,
                                    hometown: contestant.hometown,
                                    imageUrl: contestant.imageUrl,
                                    payoff: winner.payoff,
                                    time: winner.time,
                                    score: winner.score,
                                    place: winner.place == 0 ? index + 1 : winner.place,
                                    round: winner.goRound,
                                    teamId: 0,
                                    numberScores: winner.numberScores ?? 0
                                )
                            }
                        
                        return RoundWinners(
                            id: id.int,
                            round: leaders[0].roundLabel,
                            winners: leaders
                        )
                    }
                }
                
                return RoundWinners(
                    id: id.int,
                    round: roundWinners[0].roundLabel,
                    winners: roundWinners)
            }
            
            let result = RodeoResult(
                id: rodeoId,
                city: rodeo.city,
                state: rodeo.state,
                name: rodeo.name,
                rounds: winners.sorted(by: { $0.id < 555 || $1.id < 555 ? $0.id < $1.id : $0.id > $1.id})
            )
            
            await completionHandler(result)
        }
    }
}

