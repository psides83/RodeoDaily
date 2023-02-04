//
//  WidgetStandingsApi.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/4/23.
//

import Foundation
import SwiftUI

class StandingsApi: ObservableObject {
    
//    @Published var standings: [Position] = []
    
//    @Published var loading = false
    
    func getStandings(for event: StandingsEvents, selectedYear: Int = Date().yearInt, completionHandler: @escaping ([Position]) -> Void) async {
                
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
                        completionHandler(decodedItems.data)
                        
//                        print("data: \(self.standings)")
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}
