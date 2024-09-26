//
//  AthletesApi.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/12/24.
//

import Foundation
import SwiftUI

class AthletesApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var athletes = [AthleteData]()
    @Published var loading = true
    @Published var searchText = ""
    
    func getSearchResults() async {
        
        let url = apiUrls.athleteSearchUrl(from: searchText)
        
        do {
            self.athletes = try await APIService.fetchSearchAthletes(from: url).data
//            print(self.bio)
//            print(url)
//            print(self.bio.videoHighlights as Any)
            self.endLoading()
        } catch {
            self.endLoading()
            print("Error decoding: ", error)
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
