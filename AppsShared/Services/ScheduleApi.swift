//
//  RodeoScheduleApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

@MainActor
final class RodeoScheduleApi: ObservableObject {
    private let apiUrls = ApiUrls()
    
    @Published var rodeos = [RodeoData]()
    @Published var loading = false
    
    func getRodeos(index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
        let url = apiUrls.rodeoScheduleUrl(with: index, searchText: searchText, dateParams: dateParams)

        do {
            let finalData = try await PaginatedRodeoLoader.fetchPage(from: url)

            guard !finalData.isEmpty else {
                if index == 1 {
                    rodeos = []
                }
                return completionHandler()
            }

            rodeos = PaginatedRodeoLoader.mergedPage(current: rodeos, incoming: finalData, index: index)
            completionHandler()
        } catch {
            if index == 1 {
                rodeos = []
            }
            completionHandler()
        }
    }
    
    func loadRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        await getRodeos(index: index, searchText: searchText, dateParams: dateParams) {
            self.endLoading()
        }
    }
    
    func searchRodeos(for event: Events.CodingKeys,by searchText: String, in dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        removeAllResults()
        
        await getRodeos(index: 1, searchText: searchText, dateParams: dateParams) {
            self.endLoading()
        }
    }
    
    func loadRodeos(for event: Events.CodingKeys, in dateParams: String, with searchText: String, _ completionHandler: () -> Void) async {
        setLoading()
        removeAllResults()
        
        await getRodeos(index: 1, searchText: searchText, dateParams: dateParams) {
            self.endLoading()
        }
    }
    
    func removeAllResults() {
        rodeos.removeAll()
    }
    
    func setLoading() {
        loading = true
    }
    
    func endLoading() {
        loading = false
    }
}
