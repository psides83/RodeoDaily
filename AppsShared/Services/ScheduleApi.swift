//
//  RodeoScheduleApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

class RodeoScheduleApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var rodeos = [RodeoData]()
    @Published var loading = false
    
    func getRodeos(index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
        let url = apiUrls.rodeosUrl(with: index, searchText: searchText, dateParams: dateParams)
        
        do {
            let data = try await APIService.fetchRodeos(from: url).data
                        
            DispatchQueue.main.async {
                guard data.count > 0 else {
                    print("no rodeos")
                    return completionHandler()
                }
                
                print(data.map {rodeo in rodeo.name})
                
                if index > 1 {
                    self.rodeos.append(contentsOf: data)
                    completionHandler()
                } else {
                    self.rodeos = data
                    
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
        
        await getRodeos(index: index, searchText: searchText, dateParams: dateParams) {
            
            print(self.rodeos.count)
            
            self.endLoading()
        }
    }
    
    func searchRodeos(for event: Events.CodingKeys,by searchText: String, in dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        DispatchQueue.main.async {
            self.removeAllResults()
        }
        
        await getRodeos(index: 1, searchText: searchText, dateParams: dateParams) {
            
            self.endLoading()
        }
    }
    
    func loadRodeos(for event: Events.CodingKeys, in dateParams: String, with searchText: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        DispatchQueue.main.async {
            self.removeAllResults()
        }
        
        await getRodeos(index: 1, searchText: searchText, dateParams: dateParams) {
            
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
