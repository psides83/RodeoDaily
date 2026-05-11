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

    private func filteredRodeos(for event: Events.CodingKeys, from data: [RodeoData]) -> [RodeoData] {
        switch event {
        case .bb:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("bareback") }
        case .sw:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("steer") }
        case .sb:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("saddle") }
        case .td:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("tie-down") }
        case .gb:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("racing") }
        case .br:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("bull") && $0.htmlUnwrap.localizedCaseInsensitiveContains("riding") }
        case .tr:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("team") }
        case .sr:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("steer roping") }
        case .lb:
            return data.filter { $0.htmlUnwrap.localizedCaseInsensitiveContains("breakaway") }
        }
    }
    
    func getRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
        let url = apiUrls.rodeosUrl(with: index, searchText: searchText, dateParams: dateParams)
        
        do {
            let data = try await APIService.fetchRodeos(from: url).data
            
            let filteredRodeos = filteredRodeos(for: event, from: data)
            
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

    func loadInProgressRodeos(
        event: Events.CodingKeys,
        maxPages: Int = 5
    ) async {
        setLoading()

        var matches = [RodeoData]()

        for page in 1...maxPages {
            let url = apiUrls.rodeosUrl(with: page, searchText: "", dateParams: "")
            do {
                let data = try await APIService.fetchRodeos(from: url).data
                let eventRodeos = filteredRodeos(for: event, from: data)
                let inProgress = eventRodeos.filter { $0.inProgress }
                if !inProgress.isEmpty {
                    matches.append(contentsOf: inProgress)
                }
            } catch {
                print("Error decoding: ", error)
                break
            }
        }

        let unique = Dictionary(grouping: matches, by: \.id).compactMap { $0.value.first }

        await MainActor.run {
            self.rodeos = unique
                .sorted { lhs, rhs in
                    lhs.endDate < rhs.endDate
                }
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
