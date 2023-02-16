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
    
    @Published var standings: [Position] = []
    @Published var loading = false
    
    func getStandings(
        for event: StandingsEvents,
        type: StandingTypes = .world,
        circuit: Circuits = .columbiaRiver,
        selectedYear: String = Date().yearString
    ) async {
        setLoading()
                
        let url = apiUrls.standingsUrl(
            event: event,
            type: type,
            circuit: circuit,
            selectedYear: selectedYear
        )
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.standings = []
                    self.endLoading()
                }
                return
            }
                        
            guard response.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.standings = []
                    self.endLoading()
                }
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                
                do {
                    let decodedItems = try JSONDecoder().decode(Standings.self, from: data)
                    self.standings = decodedItems.data
                    self.endLoading()
                } catch let error {
                    print("Error decoding: ", error)
                }
            }
        }
        dataTask.resume()
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
