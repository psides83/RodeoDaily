//
//  ApiUrls.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation

final class ApiUrls {
    // MARK: Base Url
    let baseUrl = "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/"
    private let cloudflareBaseUrl = "https://rodeo-data-api.psides83.workers.dev/v1/prca/"
    
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

    // MARK: URL for loading daysheet data
    func rodeoDaysheetsUrl(for rodeoId: Int) -> URL {
        let urlString = baseUrl + "daysheet?id=" + rodeoId.string

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
            addDefaultStartDate: true
        )
    }

    func cloudflareSeasonRodeosUrl(
        seasonYear: Int,
        limit: Int = 200,
        offset: Int = 0,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) -> URL {
        guard var components = URLComponents(string: cloudflareBaseUrl + "rodeos") else {
            fatalError("Missing URL")
        }

        var queryItems = [
            URLQueryItem(name: "season_year", value: seasonYear.string),
            URLQueryItem(name: "limit", value: limit.string),
            URLQueryItem(name: "offset", value: offset.string)
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let startDate {
            queryItems.append(URLQueryItem(name: "start_date", value: dateFormatter.string(from: startDate)))
        }

        if let endDate {
            queryItems.append(URLQueryItem(name: "end_date", value: dateFormatter.string(from: endDate)))
        }

        components.queryItems = queryItems

        guard let url = components.url else { fatalError("Missing URL") }

        return url
    }
    
    func athleteSearchUrl(from searchText: String, pageSize: Int = 10) -> URL {
        guard var components = URLComponents(string: baseUrl + "athletes") else {
            fatalError("Missing URL")
        }
        
        components.queryItems = [
            URLQueryItem(name: "event_type", value: ""),
            URLQueryItem(name: "letter", value: ""),
            URLQueryItem(name: "page_size", value: pageSize.string),
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
            URLQueryItem(name: "circuitId", value: "")
        ]

        if type == "results" {
            items.append(URLQueryItem(name: "combine_results", value: "true"))
        }

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
