//
//  AthleteAPI.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation

class BioAPI: ObservableObject {
    
    @Published var bio: BioData = BioData()
    
    @Published var loading = true
        
    func getBio(for athleteId: Int) async {
                
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
                
                DispatchQueue.main.async {
                    
                    do {
                        
                        let decodedItems = try JSONDecoder().decode(Bio.self, from: data)
                        self.bio = decodedItems.data
                        
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
