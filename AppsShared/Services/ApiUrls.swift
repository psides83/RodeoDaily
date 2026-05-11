//
//  ApiUrls.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

class ApiUrls: ObservableObject {
    // MARK: Base Url
    let baseUrl = "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/"
    let wpraBaseUrl = "https://psides83.github.io/wpra-json/"
    
    // MARK: URL for loading athlete Bio data
    func bioUrl(for athleteId: Int) -> URL {
        let urlString = baseUrl + "athlete?id=" + athleteId.string
        
        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
        
        return url
    }
    
    // MARK: URL for loading results data
    func resultsUrl(for rodeoId: Int) -> URL {
        let urlString = baseUrl + "results?rodeoid=" + rodeoId.string
        
        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
        
        return url
    }
    
    // MARK: URL for loading results data
    func rodeosUrl(with index: Int, searchText: String, dateParams: String) -> URL {
        return scheduleUrl(
            type: "results",
            index: index,
            searchText: searchText,
            dateParams: dateParams
        )
    }
    
    // MARK: URL for loading schedule data
    func rodeoScheduleUrl(with index: Int, searchText: String, dateParams: String) -> URL {
        return scheduleUrl(
            type: "schedule",
            index: index,
            searchText: searchText,
            dateParams: dateParams,
            forceActive: nil,
            addDefaultStartDate: true
        )
    }

    func rodeoScheduleCandidateUrls(with index: Int, searchText: String, dateParams: String) -> [URL] {
        let urls = [
            // Current preferred schedule variant.
            scheduleUrl(
                type: "schedule",
                index: index,
                searchText: searchText,
                dateParams: dateParams,
                forceActive: nil,
                addDefaultStartDate: true
            ),
            // Legacy variant used by older API behavior.
            scheduleUrl(
                type: "schedules",
                index: index,
                searchText: searchText,
                dateParams: dateParams,
                forceActive: true,
                addDefaultStartDate: false
            ),
            // Fallback without forcing active but keeping legacy type.
            scheduleUrl(
                type: "schedules",
                index: index,
                searchText: searchText,
                dateParams: dateParams,
                forceActive: nil,
                addDefaultStartDate: true
            )
        ]

        var deduped: [URL] = []
        for url in urls where !deduped.contains(url) {
            deduped.append(url)
        }
        return deduped
    }
    
    // MARK: URL for loading standings data
    func standingsUrl(event: StandingsEvent, type: StandingType, circuit: Circuit, selectedYear: String) -> URL {
        var id: String {
            if type == .circuit {
                return circuit.id.string
            } else if type == .xBulls  {
                return Tour.xBulls.id.string
            } else if type == .xBroncs {
                return Tour.xBroncs.id.string
            } else if type == .legacySteerRoping {
                return Tour.legacySteerRoping.id.string
            } else {
                return ""
            }
        }
        
        var finalType: String {
            if type == .xBulls || type == .xBroncs || type == .legacySteerRoping {
                return "tour"
            } else {
                return type.rawValue
            }
        }
        
        var finalEvent: StandingsEvent {
            if type == .xBulls || type == .xBroncs || type == .legacySteerRoping {
                return .aa
            } else {
                return event
            }
        }
        
        var character: String {
            if finalEvent == .gb || finalEvent == .lb {
                return "-"
            } else {
                return "?"
            }
        }
//        let gbUrlString = wpraBaseUrl + "br_\(finalType)_\(selectedYear)_\(type == .circuit ? circuit.convertToGit : "").json"
//        let lbUrlString = wpraBaseUrl + "lb_\(finalType)_\(selectedYear)_\(type == .circuit ? circuit.convertToGit : "").json"
        let urlFilters = "standings\(character)year=\(selectedYear)&type=\(finalType)&id=\(id)&event=\(finalEvent.rawValue)"
        
        var url: URL {
            if finalEvent == .gb || finalEvent == .lb {
                print(wpraBaseUrl + urlFilters + ".json")
                guard let url = URL(string: wpraBaseUrl + urlFilters + ".json") else { fatalError("Missing URL") }
            
                return url
            } else {
                print(urlFilters)
                guard let url = URL(string: baseUrl + urlFilters) else { fatalError("Missing URL") }
            
                return url
            }
        }
        
//        guard let url = dynamicUrl else { fatalError("Missing URL") }
        
        return url
    }
    
    func athleteSearchUrl(from searchText: String) -> URL {
        guard var components = URLComponents(string: baseUrl + "athletes") else {
            fatalError("Missing URL")
        }
        
        components.queryItems = [
            URLQueryItem(name: "event_type", value: ""),
            URLQueryItem(name: "letter", value: ""),
            URLQueryItem(name: "page_size", value: "10"),
            URLQueryItem(name: "index", value: "1"),
            URLQueryItem(name: "search_term", value: searchText.trimmingCharacters(in: .whitespacesAndNewlines)),
            URLQueryItem(name: "search_type", value: ""),
            URLQueryItem(name: "exact_search", value: "null")
        ]
        
        guard let url = components.url else { fatalError("Missing URL") }
        
        return url
    }
    
    func searchSuggetionsUrl(from searchText: String) -> URL {
        guard var components = URLComponents(string: baseUrl + "autocomplete") else {
            fatalError("Missing URL")
        }
        
        components.queryItems = [
            URLQueryItem(name: "searchText", value: searchText.trimmingCharacters(in: .whitespacesAndNewlines)),
            URLQueryItem(name: "searchType", value: "contestant")
        ]
        
        guard let url = components.url else { fatalError("Missing URL") }
        
        return url
    }
    
    private func scheduleUrl(
        type: String,
        index: Int,
        searchText: String,
        dateParams: String,
        forceActive: Bool? = nil,
        addDefaultStartDate: Bool = false
    ) -> URL {
        guard var components = URLComponents(string: baseUrl + "schedule") else {
            fatalError("Missing URL")
        }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "page_size", value: "24"),
            URLQueryItem(name: "index", value: index.string),
            URLQueryItem(name: "search_term", value: searchText.trimmingCharacters(in: .whitespacesAndNewlines)),
            URLQueryItem(name: "search_type", value: ""),
            URLQueryItem(name: "tourId", value: ""),
            URLQueryItem(name: "circuitId", value: ""),
            URLQueryItem(name: "combine_results", value: "true")
        ]

        if let forceActive {
            items.append(URLQueryItem(name: "active", value: forceActive ? "true" : "false"))
        } else if type == "results" {
            // Keep results behavior, but avoid schedule being filtered to only currently active records.
            items.append(URLQueryItem(name: "active", value: "true"))
        }

        let parsedDateItems = dateQueryItems(from: dateParams)
        items.append(contentsOf: parsedDateItems)

        // Default schedule to today-forward when no explicit start/end is provided.
        if addDefaultStartDate,
           type == "schedule" || type == "schedules",
           !parsedDateItems.contains(where: { $0.name == "start" || $0.name == "end" }) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = .current
            formatter.dateFormat = "MM/d/yyyy"
            items.append(URLQueryItem(name: "start", value: formatter.string(from: Date())))
        }

        components.queryItems = items

        guard let url = components.url else { fatalError("Missing URL") }

        return url
    }
    
    private func dateQueryItems(from dateParams: String) -> [URLQueryItem] {
        let trimmed = dateParams.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return []
        }
        
        let queryString = trimmed.hasPrefix("&") ? String(trimmed.dropFirst()) : trimmed
        
        return queryString.split(separator: "&").compactMap { pair in
            let values = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            
            guard let key = values.first, !key.isEmpty else {
                return nil
            }
            
            let rawValue = values.count > 1 ? String(values[1]) : ""
            let value = rawValue.removingPercentEncoding ?? rawValue
            
            return URLQueryItem(name: String(key), value: value)
        }
    }
}
