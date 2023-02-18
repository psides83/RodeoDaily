//
//  BioExtension.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation
import SwiftUI

extension BioData {
    var name: String {
        let name = PersonNameComponents(givenName: firstName, familyName: lastName, nickname: nickName)
        
        return name.formatted(.name(style: .medium))
    }
    
    var currentRank: String {
        rankings
            .first(where: { $0.season == Date().yearInt })?
            .rank ?? NSLocalizedString("Unranked", comment: "")
    }
    
    var currentRankEvent: String {
        rankings
            .first(where: { $0.season == Date().yearInt })?
            .eventName.trimmingCharacters(in: .whitespacesAndNewlines) ?? NSLocalizedString("Unranked", comment: "")
    }
    
    var athleteAge: String {
        guard let checkAge = age else { return NSLocalizedString("unknown", comment: "") }
        
        return checkAge.string
    }
    
    var worldTitlesCount: String {
        guard let titles = worldTitles else { return NSLocalizedString("No World Titles", comment: "") }
        
        switch titles {
            case 0: return NSLocalizedString("No World Titles", comment: "")
        case 1: return titles.string + NSLocalizedString(" World Title", comment: "")
        default: return titles.string + NSLocalizedString(" World Titles", comment: "")
        }
    }
    
    var careerEarnings: String {
        guard let earnings = totalEarnings else { return NSLocalizedString("No Career Earnings", comment: "") }
        
        return earnings.shortenedCurrency + NSLocalizedString(" Career Earnings", comment: "")
    }
    
    var nfrQuals: String {
        guard let nfrs = nfrQualifications else { return NSLocalizedString("No NFRs", comment: "") }
        
        if nfrs == 1 { return nfrs.string + NSLocalizedString(" NFR", comment: "") }
        else { return nfrs.string + NSLocalizedString(" NFR's", comment: "") }
    }
    
    var image: some View {
        guard let url = imageUrl else {
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.5)
            }
        }
        
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
        } placeholder: {
            Color.gray.opacity(0.5)
        }
    }
    
    // Removes previous season's NFR from results and adds it to the previous season's results.
    func baseResults(for season: Int) -> [BioResult] {
        let nextSeason = season + 1
        
        let currentNfr = results
            .filter({
                $0.seasonMatches(season: nextSeason)
                &&
                $0.rodeoName.localizedCaseInsensitiveContains("National Finals")
            })
        
        let currentSeason = results
            .filter({
                $0.seasonMatches(season: season)
                &&
                $0.rodeoName.localizedCaseInsensitiveContains("National Finals") == false })
        
        return currentNfr + currentSeason
    }
    
    // Provides the bio results filtered by season, event, and a search term that is provided by the view.
    func results(
        filteredBy season: Int,
        filteredBy event: String,
        searchText: String,
        sortedBy keyPath: BioResult.SortingKeyPath
    ) -> [BioResult] {
        let searchedResults = baseResults(for: season).filter({
            if searchText.isEmpty {
                return true
            } else {
                return $0.rodeoName.localizedCaseInsensitiveContains(searchText) || $0.result.localizedCaseInsensitiveContains(searchText)
            }
        })
        
        switch keyPath {
        case .rodeoDate:
            return searchedResults.filter({ $0.eventType == event }).sorted(by: { $0.endDate > $1.endDate })
        case .result:
            return searchedResults.filter({
                $0.eventType == event
                &&
                $0.resultDisplay != "NT"
                &&
                $0.resultDisplay != "NS"
            }).sorted(by: {
                if $0.isRoughStock {
                    return $0.resultDisplay.double > $1.resultDisplay.double
                } else {
                    return $0.resultDisplay.double < $1.resultDisplay.double
                }
            })
            +
            searchedResults.filter({
                $0.eventType == event
                &&
                ($0.resultDisplay == "NT" || $0.resultDisplay == "NS")
                
            })
        case .earnings:
            return searchedResults
                .filter({ $0.eventType == event })
                .sorted(by: { $0.payoff > $1.payoff })
        }
    }
    
    func careerSeasons(filteredBy event: StandingsEvent) -> [CareerWithEarinings] {
        var adjustedEvent: String {
            if event == .hd || event == .hl {
                return "TR"
            } else {
                return event.rawValue
            }
        }
        
        let careerRankings = rankings.filter({ $0.eventName.localizedCaseInsensitiveContains(event.title.localizedLowercase.prefix(4)) })
        
        let finalCareerData = careerRankings.map { season in
            let careerEarnings = career
                .filter({
                    $0.eventType == adjustedEvent
                    &&
                    $0.season.string == season.season.string
                })
            
            guard careerEarnings
                .count > 0 else {
                return CareerWithEarinings(season: "", rank: "", standingType: "", earnings: "")
            }
            
            return CareerWithEarinings(
                season: season.season.string,
                rank: season.rank,
                standingType: "World",
                earnings: careerEarnings[0].earnings.currencyABS)
        }
        
        guard finalCareerData.count > 0 else { return [] }
        
        return finalCareerData
            .filter({ $0.season != "" })
            .sorted(by: {$0.season > $1.season })
    }
}

extension BioResult {
    var location: String {
        "\(city), \(state)"
    }
    
    var isRoughStock: Bool {
        switch eventType {
            case "BR", "SB", "BB": return true
            default: return false
        }
    }
    
    var result: String {
        if isRoughStock {
            return score.string
        } else {
            return time.string
        }
    }
    
    var resultDisplay: String {
        let nonQualifier = isRoughStock ? "NS" : "NT"
        
        switch result {
            case "0.0", "-99.0": return nonQualifier
            default: return result
        }
    }
    
    var roundDisplay: String {
        switch round {
            case "Avg", "Finals": return round
            default: return "Round \(round)"
        }
    }
    
    var placeDisplay: String {
        guard place.string != "99" && place.string != "9999" else { return "  -"}
        
        guard place.string != "11" && place.string != "12" && place.string != "13" else { return "\(place)th"}
        
        switch place.string.last {
            case "1": return "\(place)st"
            case "2": return "\(place)nd"
            case "3": return "\(place)rd"
            case "0": return "  -"
            default: return "\(place)th"
        }
    }
    
    var payoutDisplay: String {
        if payoff == 0.0 {
            return "-  "
        } else {
            return payoff.currencyABS
        }
    }
    
    enum SortingKeyPath: String, CaseIterable, Equatable, Identifiable {
        case rodeoDate, result, earnings
        
        var title: String {
            switch self {
            case .rodeoDate: return NSLocalizedString("Date", comment: "")
            case .result: return NSLocalizedString("Time/Score", comment: "")
            case .earnings: return NSLocalizedString("Earnings", comment: "")
            }
        }
        
        var id: String { rawValue }
    }
    
    func seasonMatches(season: Int) -> Bool {
        if season == seasonYear {
            return true
        }
        
        return false
    }
}
