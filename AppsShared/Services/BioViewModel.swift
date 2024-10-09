//
//  AthleteAPI.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation
import SwiftData
import SwiftUI

class BioViewModel: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    @ObservedObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.5)
    
    @Published var bio: BioData = BioData()
    @Published var selectedEvent: String?
    @Published var selectedSeason = Date().yearString
    @Published var sortResultsBy: BioResult.SortingKeyPath = .rodeoDate
    @Published var infoType: BioInfoType = .results
    @Published var showSearchBar = false
    @Published var loading = false

    
    enum BioInfoType: String, CaseIterable {
        case bio = "Bio"
        case results = "Results"
        case career = "Career"
        case highlights = "Highlights"
    }
    
    // MARK: - Methods
    func setSelectedEvent(_ event: String) async {
        self.selectedEvent = event
    }
    
    func getBio(for athleteId: Int) async {
        setLoading()
        
        let url = apiUrls.bioUrl(for: athleteId)
        
        do {
            self.bio = try await APIService.fetchBio(from: url).data
            if selectedEvent == nil {
                self.selectedEvent = bio.topEvent.withTeamRopingConversion
            }
            print(self.bio.contestantId)
//            print(self.bio.events)
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
    
    func seasonRanking() -> String {
        guard let event = selectedEvent else { return "No event selected" }
        let ranking = bio.currentSeasonRankings().first(where: { $0.event == event })
        
        if let rank = ranking {
            let eventName = rank.eventName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return "\(rank.ranking) in \(eventName) with \(rank.earnings.currencyABS)"
        }
        
        return "Unranked in \(event.eventDisplay)"
    }
    
    // MARK: - Computed Properties
    var results: [BioResult] {
        if let event = selectedEvent {
            return bio.results(
                filteredBy: selectedSeason.int,
                filteredBy: event,
                searchText: search.text,
                sortedBy: sortResultsBy
            )
        }
        
        return []
    }

    var currentYearEarnings: String {
        guard let event = selectedEvent else { return "No Event Selected" }
        
        return bio
            .career
            .filter({
                $0.season == Date().yearInt
                &&
                $0.eventType == event
                
            })[0]
            .earnings
            .currencyABS
    }
    
    var careerSeasons: [CareerWithEarinings] {
        bio.careerSeasons(filteredBy: selectedEvent)
    }
}
