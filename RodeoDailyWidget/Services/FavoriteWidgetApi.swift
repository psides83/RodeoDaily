//
//  ContestantWidget.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/9/23.
//

import Foundation

class FavoriteWidgetApi: ObservableObject {
    
    func loadBio(for athleteId: Int, completionHandler: @escaping (BioData) async -> Void) async {
        
        guard let url = URL(string:
                                "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/athlete?id=\(athleteId)"
        ) else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                guard let data = data else { return }
                
                Task {
                    
                    do {
                        
                        let decodedItems = try JSONDecoder().decode(Bio.self, from: data)
                        
                        await completionHandler(decodedItems.data)
                    } catch let error {
                        
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}
