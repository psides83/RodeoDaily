//
//  SearchSuggetionsApi.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/12/24.
//

import Foundation
import SwiftUI

class SearchSuggetionsApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var suggestions = [SearchResultElement]()
    @Published var loading = true
    @Published var index = 1
//    @Published var searchText = ""
    
    func getSearchResults(from searchText: String) async {
        setLoading()
        
        let url = apiUrls.searchSuggetionsUrl(from: searchText)
                
        do {
            suggestions = []
            
            try await APIService.fetchSearchSuggestions(from: url).data.forEach {
                suggestion in
//                print(suggestion.value.data[0])
                suggestions.append(suggestion.value.data[0])
            }
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
//            print("loading ended")
        }
    }
}
