//
//  SearchSuggetionsApi.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/12/24.
//

import Foundation
import SwiftUI

@MainActor
final class SearchSuggetionsApi: ObservableObject {
    private let apiUrls = ApiUrls()
    
    @Published var suggestions = [SearchResultElement]()
    @Published var loading = true
    @Published var index = 1
//    @Published var searchText = ""
    
    func getSearchResults(from searchText: String) async {
        loading = true
        suggestions = []

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            loading = false
            return
        }
        
        let url = apiUrls.searchSuggetionsUrl(from: searchText)
                
        do {
            let response = try await APIClient.fetch(SearchSuggestion.self, from: url)
            suggestions = response.data.values
                .flatMap(\.data)
                .reduce(into: [SearchResultElement]()) { results, suggestion in
                    guard !results.contains(where: { $0.id == suggestion.id }) else {
                        return
                    }
                    results.append(suggestion)
                }
            loading = false
        } catch {
            loading = false
        }
    }
}
