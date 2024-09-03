//
//  standings-api.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import Foundation
import SwiftUI

class StandingsApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var standings = [Position]()
    @Published var loading = false
    
    func getStandings(
        for event: StandingsEvent,
        type: StandingType = .world,
        circuit: Circuit = .columbiaRiver,
        selectedYear: String = Date().yearString
    ) async {
        setLoading()
                
        let url = apiUrls.standingsUrl(
            event: event,
            type: type,
            circuit: circuit,
            selectedYear: selectedYear
        )
        
        do {
            if event == .gb || event == .lb {
                #if os(iOS)
                standings = try await WpraScraper.scrape(event: event, type: type, year: selectedYear, circuit: circuit)
                #endif
            } else {
                standings = try await APIService.fetchStandings(from: url).data
            }
            endLoading()
        } catch {
            DispatchQueue.main.async {
                self.standings = []
                self.endLoading()
                print("Error decoding: ", error)
            }
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
