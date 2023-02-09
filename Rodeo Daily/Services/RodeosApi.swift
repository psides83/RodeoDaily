//
//  RodeosApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

class RodeosApi: ObservableObject {
    
    @Published var rodeos: [RodeoData] = []
        
    @Published var loading = false
    
    func getRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
                
        guard let url = URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/schedule?type=results&page_size=24&index=\(index)&active=true&search_term=\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))&search_type=&tourId=&circuitId=&combine_results=true\(dateParams)") else { fatalError("Missing URL") }
        
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
                            return completionHandler()
                        }
                        
                        print(filteredRodeos.map {rodeo in rodeo.name})
                                                
                        if index > 1 {
                            self.rodeos.append(contentsOf: filteredRodeos)
                            completionHandler()
                        } else {
                            self.rodeos = filteredRodeos
                        
                        completionHandler()
//                      //  print("data: \(decodedItems.data)")
                        }
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func loadRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        // if index == 1 {
        //     DispatchQueue.main.async {
        //         self.removeAllResults()
        //     }
        // }
        
        await getRodeos(event: event, index: index, searchText: searchText, dateParams: dateParams) {
            
            print(self.rodeos.count)
            
            self.endLoading()
        }
    }
    
    func searchRodeos(for event: Events.CodingKeys,by searchText: String, in dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        DispatchQueue.main.async {
            self.removeAllResults()
        }
        
        await getRodeos(event: event, index: 1, searchText: searchText, dateParams: dateParams) {
            
            self.endLoading()
        }
    }
    
    func loadRodeos(for event: Events.CodingKeys, in dateParams: String, with searchText: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        DispatchQueue.main.async {
            self.removeAllResults()
        }
        
        await getRodeos(event: event, index: 1, searchText: searchText, dateParams: dateParams) {
            
            self.endLoading()
        }
    }
    
    func removeAllResults() {
            DispatchQueue.main.async {
                self.rodeos.removeAll()
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
            print("loading ended")
        }
    }
}
