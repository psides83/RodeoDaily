//
//  ResultsApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

class ResultsApi: ObservableObject {
    
    @Published var results = RodeoResult(id: 0, city: "", state: "", name: "", rounds: [])
//    @Published var events = Events(bb: nil, sw: nil, sb: nil, td: nil, gb: nil, br: nil, tr: nil, lb: nil)
        
    @Published var loading = true
    
//    func fetchRodeos(index: Int, searchText: String, dateParams: String, completionHandler: @escaping ([RodeoData]) -> Void) async {
//                
//        guard let url = URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/schedule?type=results&page_size=24&index=\(index)&active=true&search_term=\(searchText)&search_type=&tourId=&circuitId=&combine_results=true\(dateParams)") else { fatalError("Missing URL") }
//        
//        let urlRequest = URLRequest(url: url)
//        
//        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//            
//            if let error = error {
//                print("Request error: ", error)
//                return
//            }
//            
//            guard let response = response as? HTTPURLResponse else { return }
//            
//            if response.statusCode == 200 {
//                
//                guard let data = data else { return }
//                
//                DispatchQueue.main.async {
//                    
//                    do {
//                        let decodedItems = try JSONDecoder().decode(RodeoSchedule.self, from: data)
//                        //                        self.rodeos = decodedItems.data
//                        
//                        completionHandler(decodedItems.data)
//                        
//                        print("data: \(decodedItems.data)")
//                    } catch let error {
//                        
//                        print("Error decoding: ", error)
//                    }
//                }
//            }
//        }
//        dataTask.resume()
//    }
    
    func fetchResults(rodeoId: Int, event: Events.CodingKeys, _ completionHandler: @escaping (Datum, [String: [Round]]) -> Void) async {
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
