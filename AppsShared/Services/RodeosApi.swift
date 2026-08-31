//
//  RodeosApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

@MainActor
final class RodeosApi: ObservableObject {
    private let apiUrls = ApiUrls()
    
    @Published var rodeos = [RodeoData]()
    @Published var loading = false
    
    func getRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
        let url = apiUrls.rodeosUrl(with: index, searchText: searchText, dateParams: dateParams)
        
        do {
            let page = try await PaginatedRodeoLoader.fetchPage(from: url, event: event)

            guard !page.isEmpty else {
                return completionHandler()
            }

            rodeos = PaginatedRodeoLoader.mergedPage(current: rodeos, incoming: page, index: index)
            completionHandler()
        } catch {
            completionHandler()
        }
    }
    
    func loadRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        await getRodeos(event: event, index: index, searchText: searchText, dateParams: dateParams) {
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
                let rodeos = try await PaginatedRodeoLoader.fetchPage(from: url, event: event)
                let inProgress = rodeos.filter { $0.inProgress }
                if !inProgress.isEmpty {
                    matches.append(contentsOf: inProgress)
                }
            } catch {
                break
            }
        }

        let unique = PaginatedRodeoLoader.uniqueById(matches)

        rodeos = unique
            .sorted { lhs, rhs in
                lhs.endDate < rhs.endDate
            }
        endLoading()
    }
    
    func searchRodeos(for event: Events.CodingKeys,by searchText: String, in dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        removeAllResults()
        
        await getRodeos(event: event, index: 1, searchText: searchText, dateParams: dateParams) {
            self.endLoading()
        }
    }
    
    func loadRodeos(for event: Events.CodingKeys, in dateParams: String, with searchText: String, _ completionHandler: () -> Void) async {
        setLoading()
        removeAllResults()
        
        await getRodeos(event: event, index: 1, searchText: searchText, dateParams: dateParams) {
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
