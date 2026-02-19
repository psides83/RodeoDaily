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
//    @ObservedObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.5)
    
    @Published var bio: BioData = BioData()
    @Published var selectedEvent: String?
    @Published var selectedSeason = Date().yearString
    @Published var sortResultsBy: BioResult.SortingKeyPath = .rodeoDate
    @Published var infoType: BioInfoType = .stats
    @Published var showSearchBar = false
    @Published var loading = false
    @Published var searchText = ""
    
//    let months = DateFormatter().shortMonthSymbols
    
    enum BioInfoType: String, CaseIterable {
        case bio = "Bio"
        case results = "Results"
        case stats = "Stats"
        case career = "Career"
        case highlights = "Highlights"
    }
    
    enum Months: String, CaseIterable {
        case jan = "Jan"
        case feb = "Feb"
        case mar = "Mar"
        case apr = "Apr"
        case may = "May"
        case jun = "Jun"
        case jul = "Jul"
        case aug = "Aug"
        case sep = "Sep"
        case oct = "Oct"
        case nov = "Nov"
        case dec = "Dec"
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
//            print(self.bio.contestantId)
//            print(self.bio.events)
//            print(self.bio)
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
    
    func stats(season: String) -> (
        seasonEarningsAndRank: (rank: String, earnings: String),
        bestGo: (rodeo: String, result: String),
        earningsGo: (rodeo: String, result: String, payout: String),
        earningRodeo: (rodeo:String, payout: String)
    ) {
        let seasonResults = bio.results
            .filter {
                $0.seasonMatches(season: season.int)
                &&
                $0.eventType == selectedEvent
                &&
                !$0.rodeoName.localizedCaseInsensitiveContains("national finals rodeo")
            }
        
        let resultsWithAve = bio.resultsAndAveragesCombined()
            .filter {
                $0.seasonMatches(season: season.int)
                &&
                $0.eventType == selectedEvent
                &&
                !$0.rodeoName.localizedCaseInsensitiveContains("national finals rodeo")
            }
        
        return (
            seasonEarningsAndRank(season: season),
            bestGo(results: seasonResults),
            earningsGo(results: seasonResults),
            earningsRodeo(results: resultsWithAve)
        )
    }
    
    func seasonEarningsAndRank(season: String) -> (rank: String, earnings: String) {
        let seasons = careerSeasons.filter({ $0.season == season })
        
        guard seasons.count > 0 else { return ("Unranked", "No Earnings") }
        
        let careerSeason = seasons[0]
        
        let rank = careerSeason.rank
        let earnings = careerSeason.earnings
        
        return (rank, earnings)
    }
    
    func bestGo(results: [BioResult]) -> (rodeo: String, result: String) {
        if selectedEvent == "BR" || selectedEvent == "BB" || selectedEvent == "SB" {
            if results.filter({ $0.score > 0 }).sorted(by: { $0.score < $1.score }).count > 0 {
                
                let best = results.sorted { $0.score > $1.score }[0]
                let rodeo = best.rodeoName
                let result = best.resultDisplay
                
                return (rodeo: rodeo, result: result)
            }
            
            return (rodeo: "No Reaults", result: "-")
        } else {
            if results.filter({ $0.time > 0 }).sorted(by: { $0.time < $1.time }).count > 0 {
                
                let best = results.filter({ $0.time > 0 }).sorted(by: { $0.time < $1.time })[0]
                let rodeo = best.rodeoName
                let result = best.resultDisplay
                
                return (rodeo: rodeo, result: result)
            }
            
            return (rodeo: "No Reaults", result: "-")
        }
    }
    
    func earningsGo(results: [BioResult]) -> (
        rodeo: String,
        result: String,
        payout: String
    ) {
        let highest = results.max(by: { $0.payoff < $1.payoff })
        
        guard let highest else { return (rodeo: "No Results", result: "-", payout: "-") }
        
        return (rodeo: highest.rodeoName, result: highest.resultDisplay, payout: highest.payoutDisplay)
    }
    
    func earningsRodeo(results: [BioResult]) -> (rodeo: String, payout: String)  {
        let highest = results
            .reduce(into: [Int: (name: String, total: Double)]()) { dict, result in
                dict[result.rodeoId, default: (result.rodeoName, 0)].total += result.payoff
            }
            .max(by: { $0.value.total < $1.value.total })
        
        guard let highest else { return (rodeo: "No Results", payout: "-") }
        
        return (rodeo: highest.value.name, payout: highest.value.total.currencyABS)
        
    }
    
    func nfrBestGo(season: Int) -> String? {
        let seasonResults = bio.results
            .filter {
                $0.seasonYear - 1 == season
                &&
                $0.eventType == selectedEvent
                &&
                $0.rodeoName.localizedCaseInsensitiveContains("national finals")
            }
        
        if seasonResults.count > 0 {
            if selectedEvent == "BR" || selectedEvent == "BB" || selectedEvent == "SB" {
                let best = seasonResults.sorted { $0.score > $1.score }[0]
                let result = best.resultDisplay
                
                return result
            } else {
                let best = seasonResults.filter { $0.time > 0 }.sorted { $0.time < $1.time }[0]
                let result = best.resultDisplay
                
                return result
            }
        } else {
            return nil
        }
    }
    
    func monthlyEarnings(season: String) -> [(month: String, total: Double)] {
        let seasonResults = bio.resultsAndAveragesCombined()
            .filter {
                $0.seasonMatches(season: season.int)
                &&
                $0.eventType == selectedEvent
            }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Build your fiscal year month order: Oct → Sep
        let fiscalMonths = ["Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep"]
        
        // Filter for results belonging to this season window
        let filteredResults = seasonResults.filter { result in
            guard let date = formatter.date(from: result.startDate) else { return false }
            let year = Calendar.current.component(.year, from: date)
            let month = date.monthAbreviated
            
            // Handle Oct–Dec of *previous year* for current season
            if ["Oct", "Nov", "Dec"].contains(month) {
                return year == season.int - 1
            } else {
                return year == season.int
            }
        }
        
        // Group by month abbreviation
        let grouped = filteredResults.reduce(into: [String: Double]()) { totals, result in
            guard let date = formatter.date(from: result.endDate) else { return }
            let month = date.monthAbreviated
            
            // Exclude NFR unless you want to count it separately
            if result.rodeoName.localizedCaseInsensitiveContains("national finals") {
                return
            }
            
            totals[month, default: 0] += result.payoff
        }
        
        // Fill missing months with 0
        let totals = fiscalMonths.map { month in
            (month, grouped[month] ?? 0)
        }
        
        return totals
    }
    
    func nfrEarnings(for season: String) -> String? {
//        print("season -", season)
        let results = bio.resultsAndAveragesCombined()
            .filter {
                $0.seasonYear - 1 == season.int
                &&
                $0.eventType == selectedEvent
                &&
                $0.rodeoName.localizedCaseInsensitiveContains("national finals")
            }
        
//        print(results)
        
        if results.isEmpty { return nil }
        
        return results.reduce(0) { $0 + $1.payoff }.currencyABS
    }
    
    // MARK: - Computed Properties
    var results: [BioResult] {
        if let event = selectedEvent {
            return bio.results(
                filteredBy: selectedSeason.int,
                filteredBy: event,
                searchText: searchText,
                sortedBy: sortResultsBy
            )
        }
        
        return []
    }
    
    var scoreTypeText: (scoreType: String, action: String) {
        if selectedEvent == "BR" || selectedEvent == "BB" || selectedEvent == "SB" {
            return (scoreType: "Highest Score:", action: "Ride")
        } else {
            
            return (scoreType: "Fastest Time:", action: "Run")
        }
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

extension Date {
    var monthAbreviated: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
}
