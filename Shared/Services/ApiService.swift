//
//  ApiService.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/23/23.
//

import Foundation

enum APIService {
    static func fetch<T: Decodable>(from url: URL, completionHandler: @escaping (T) -> Void) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(T.self, from: data)
        
        completionHandler(result)
    }
    
    static func fetch<T: Decodable>(from url: URL) async throws -> T {
        let (todoData, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(T.self, from: todoData)
                
        return result
    }
    
    static func fetchBio(from url: URL) async throws -> Bio {
        return try await APIService.fetch(from: url)
    }
    
    static func fetchStandings(from url: URL) async throws -> Standings {
        return try await APIService.fetch(from: url)
    }
    
    static func fetchRodeos(from url: URL) async throws -> RodeoSchedule {
        return try await APIService.fetch(from: url)
    }
    
    static func fetchResults(from url: URL) async throws -> RodeoResults {
        return try await APIService.fetch(from: url)
    }
    
    static func fetchSearchAthletes(from url: URL) async throws -> AthleteList {
        return try await APIService.fetch(from: url)
    }
    
    static func fetchSearchSuggestions(from url: URL) async throws -> SearchSuggestion {
        return try await APIService.fetch(from: url)
    }
}
