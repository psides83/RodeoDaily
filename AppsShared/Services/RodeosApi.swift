//
//  RodeosApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

class RodeosApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var rodeos = [RodeoData]()
    @Published var loading = false
    
    func getRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
        let url = apiUrls.rodeosUrl(with: index, searchText: searchText, dateParams: dateParams)
        
        do {
            let data = try await APIService.fetchRodeos(from: url).data
            
            var filteredRodeos: [RodeoData] = []
            
            switch event {
            case .bb:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("bareback") })
            case .sw:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("steer") })
            case .sb:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("saddle") })
            case .td:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("tie-down") })
            case .gb:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("racing") })
            case .br:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("bull") && $0.htmlUnwrap.localizedCaseInsensitiveContains("riding")})
            case .tr:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("team") })
            case .sr:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("steer roping") })
            case .lb:
                filteredRodeos = data.filter({ $0.htmlUnwrap.localizedCaseInsensitiveContains("breakaway") })
            }
            
            DispatchQueue.main.async {
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
                }
            }
        } catch {
            completionHandler()
            print("Error decoding: ", error)
        }
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
