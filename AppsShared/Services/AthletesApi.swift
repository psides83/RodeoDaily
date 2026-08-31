//
//  AthletesApi.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/12/24.
//

import Foundation
import SwiftUI

class AthletesApi: ObservableObject {
    private let apiUrls = ApiUrls()
    
    @Published var athletes = [AthleteData]()
    @Published var loading = true
    @Published var searchText = ""
    
    func getSearchResults() async {
        
        let url = apiUrls.athleteSearchUrl(from: searchText)
        
        do {
            let response = try await APIClient.fetch(AthleteList.self, from: url)
            self.athletes = response.data
            self.endLoading()
        } catch {
            self.endLoading()
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
        }
    }
}
