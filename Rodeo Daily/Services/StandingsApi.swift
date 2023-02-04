//
//  standings-api.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import Foundation
import SwiftUI

class StandingsApi: ObservableObject {
    
    @Published var standings: [Position] = []
    
    @Published var loading = false
    
    func getStandings(for event: StandingsEvents, selectedYear: Int = Date().yearInt) async {
        
        setLoading()
        
        guard let url = URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/standings?year=\(selectedYear.string)&type=world&id=&event=\(event.rawValue)") else { fatalError("Missing URL") }
        
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
                        
                        let decodedItems = try JSONDecoder().decode(Standings.self, from: data)
                        self.standings = decodedItems.data
                        
//                        print("data: \(self.standings)")
                        self.endLoading()
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
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
