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
    
    func getStandings(for event: StandingsEvents, type: StandingTypes = .world, circuit: Circuits = .columbiaRiver, selectedYear: Int = Date().yearInt) async {
        
        setLoading()
        
        var id: String {
            if type == .circuit {
                return circuit.id.string
            } else if type == .xBulls  {
                return Tours.xBulls.id.string
            } else if type == .xBroncs {
                return Tours.xBroncs.id.string
            } else if type == .legacySteerRoping {
                return Tours.legacySteerRoping.id.string
            } else {
                return ""
            }
        }
        
        var finalType: String {
            if type == .xBulls || type == .xBroncs || type == .legacySteerRoping {
                return "tour"
            } else {
                return type.rawValue
            }
        }
        
        var finalEvent: StandingsEvents {
            if type == .xBulls || type == .xBroncs || type == .legacySteerRoping {
                return .aa
            } else {
                return event
            }
        }
        
        print(id)
        
        var dynamicUrl: URL? {
            if finalEvent == .gb {
                return URL(string: "https://us-central1-rodeo-daily.cloudfunctions.net/wpra/br/\(type)/\(selectedYear.string)/\(circuit.convertToWpra)")
            } else if finalEvent == .lb {
                return URL(string: "https://us-central1-rodeo-daily.cloudfunctions.net/wpra/lb/\(type)/\(selectedYear.string)/\(circuit.convertToWpra)")
            } else {
                return URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/standings?year=\(selectedYear.string)&type=\(finalType)&id=\(id)&event=\(finalEvent.rawValue)")
            }
        }
                
        guard let url = dynamicUrl else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                Task {
                    self.standings = []
                }
                self.endLoading()
                return
            }
                        
            guard response.statusCode == 200 else {
                Task {
                    self.standings = []
                }
                self.endLoading()
                return
            }
            
            guard let data = data else { return }
            
            Task {
                
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
