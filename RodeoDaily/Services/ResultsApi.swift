//
//  ResultsApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

class ResultsApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var results = RodeoResult(id: 0, city: "", state: "", name: "", rounds: [])
    @Published var loading = true
    
    func fetchResults(rodeoId: Int, event: Events.CodingKeys, _ completionHandler: @escaping (Datum, [String: [Round]]) -> Void) async {
        let url = apiUrls.resultsUrl(for: rodeoId)
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    
                    do {
                        
                        let decodedItems = try JSONDecoder().decode(RodeoResults.self, from: data)
                        
                        guard decodedItems.data != nil else { return }
                        guard decodedItems.data![0].events != nil else { return }
                                                
                        switch event {
                        case .bb:
                            guard decodedItems.data![0].events?.bb != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.bb!)!)
                        case .sw:
                            guard decodedItems.data![0].events?.sw != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.sw!)!)
                        case .sb:
                            guard decodedItems.data![0].events?.sb != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.sb!)!)
                        case .td:
                            guard decodedItems.data![0].events?.td != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.td!)!)
                        case .gb:
                            guard decodedItems.data![0].events?.gb != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.gb!)!)
                        case .br:
                            guard decodedItems.data![0].events?.br != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.br!)!)
                        case .tr:
                            guard decodedItems.data![0].events?.tr != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.tr!)!)
                        case .lb:
                            guard decodedItems.data![0].events?.lb != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.lb!)!)
                        case .sr:
                            guard decodedItems.data![0].events?.sr != nil else { return }
                            completionHandler(decodedItems.data![0], (decodedItems.data![0].events?.sr!)!)
                        }


                        
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func getWinners(rodeoId: Int, event: Events.CodingKeys, _ completionHandler: @escaping (RodeoResult) -> Void) async {
                
        await fetchResults(rodeoId: rodeoId, event: event) { (rodeo, rounds) in
                        
            let winners = rounds.map { round in
                
                let id = round.key

                let roundWinners = round.value.filter({ $0.payoff != 0 }).sorted(by: { $0.payoff > $1.payoff }).map { winner in
                    let contestant = winner.contestant[0]
                    let winnerId = "\(id)\(contestant.id)"
                    let contestantName = contestant.nickName != "" ? "\(contestant.nickName ?? "") \(contestant.lastName)" : "\(contestant.firstName) \(contestant.lastName)"

                    return Winner(id: winnerId.int, contestantId: contestant.id, roundLabel: winner.goRoundLabel, name: contestantName, hometown: contestant.hometown, imageUrl: contestant.imageUrl, payoff: winner.payoff, time: winner.time, score: winner.score, place: winner.place, round: winner.goRound)
                }

                guard roundWinners.count != 0 else {
                    let leaders = round.value.filter({ $0.time != 0 || $0.score != 0 }).sorted(by: { $0.time < $1.time }).sorted(by: { $0.score > $1.score }).prefix(10).enumerated().map { (index, winner) in
                        let contestant = winner.contestant[0]
                        let winnerId = "\(id)\(contestant.id)"

                        return Winner(id: winnerId.int, contestantId: contestant.id, roundLabel: winner.goRoundLabel, name: contestant.name, hometown: contestant.hometown, imageUrl: contestant.imageUrl, payoff: winner.payoff, time: winner.time, score: winner.score, place: winner.place == 0 ? index + 1 : winner.place, round: winner.goRound)
                    }
                    return RoundWinners(id: id.int, round: leaders[0].roundLabel, winners: leaders)
                }

                return RoundWinners(id: id.int, round: roundWinners[0].roundLabel, winners: roundWinners)
            }
            
            let result = RodeoResult(id: rodeoId, city: rodeo.city, state: rodeo.state, name: rodeo.name, rounds: winners.sorted(by: { $0.id < 555 || $1.id < 555 ? $0.id < $1.id : $0.id > $1.id}))
            
//            self.results = result
            
            completionHandler(result)
        }
    }
    
    func loadResults(rodeoId: Int, event: Events.CodingKeys, _ completionHandler: @escaping () -> Void) async {
        
        await getWinners(rodeoId: rodeoId, event: event) { data in
            self.results = data
            
            completionHandler()
        }
    }
    
    func setLoading() {
        DispatchQueue.main.async {
            self.loading = true
        }
    }
    
    func endLoading() {
        DispatchQueue.main.async {
            self.loading = false
//            print("loading ended")
        }
    }
}
