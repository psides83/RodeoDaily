//
//  StandingsServiceConfig.swift
//  RodeoDaily
//
//  Created by Payton Sides on 5/9/26.
//

import Foundation

class StandingsServiceConfig {
    static let rodeoDataApiURL = "https://rodeo-data-api.psides83.workers.dev"
    
    func getWpraUrl(
        normalizedType: String = "world",
        seasonYear: Int,
        event: StandingsEvent,
        type: StandingType,
        circuit: Circuit = .columbiaRiver
    ) throws -> URLRequest {
        guard var components = URLComponents(
            string: "\(StandingsServiceConfig.rodeoDataApiURL)/v1/wpra/standings"
        ) else {
            throw URLError(.badURL)
        }
        
        components.queryItems = [
            URLQueryItem(name: "season_year", value: "\(seasonYear)"),
            URLQueryItem(name: "event", value: event.rawValue),
            URLQueryItem(name: "type", value: normalizedType),
            URLQueryItem(name: "refresh", value: Self.wpraWeeklyRefreshKey())
        ]
        
        if type == .circuit {
            components.queryItems?.append(
                URLQueryItem(name: "circuit_id", value: "\(circuit.id)")
                
            )
            
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30
        )
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        return request
    }
    
    func getPastChampionsUrl() throws -> URLRequest {
        guard var components = URLComponents(
            string: "\(StandingsServiceConfig.rodeoDataApiURL)/v1/past-champions"
        ) else {
            throw URLError(.badURL)
        }
        
        components.queryItems = []
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        return request
    }

    private static func wpraWeeklyRefreshKey(date: Date = Date()) -> String {
        let updateHourUTC = 12
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var mondayNoon = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        mondayNoon = calendar.date(byAdding: .hour, value: updateHourUTC, to: mondayNoon) ?? mondayNoon

        if date < mondayNoon {
            mondayNoon = calendar.date(byAdding: .day, value: -7, to: mondayNoon) ?? mondayNoon
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: mondayNoon)
    }
}
