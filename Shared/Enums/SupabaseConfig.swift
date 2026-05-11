//
//  SupabaseConfig.swift
//  RodeoDaily
//
//  Created by Payton Sides on 5/9/26.
//

import Foundation

class SupabaseConfig {
    static let projectURL = "https://achpzqhveafdqkdufwhk.supabase.co"
    static let publishableKey = "sb_publishable_61Zt6GCmZ6eoowr3YqgGsw_ZvHj_UQX"
    
    func getURL(
        normalizedType: String = "world",
        seasonYear: Int,
        event: StandingsEvent,
        type: StandingType,
        circuit: Circuit = .columbiaRiver
    ) throws -> URLRequest {
        //        let typeValue = normalizedType(type.rawValue) ?? "world"
        //        var query = "\(projectURL)/rest/v1/standings?select=*"
        //        query += "&season_year=eq.\(seasonYear)"
        //        query += "&event=eq.\(event.rawValue)"
        //        query += "&type=eq.\(typeValue)"
        //        if type == .circuit {
        //            query += "&circuit_id=eq.\(circuit.id)"
        //        }
        //        query += "&order=place.asc,earnings.desc"
        //
        //        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        //              let url = URL(string: encoded) else {
        //            return []
        //        }
        
        //        let typeValue = normalizedType(type.rawValue) ?? "world"
        
        guard var components = URLComponents(
            string: "\(SupabaseConfig.projectURL)/rest/v1/standings"
        ) else {
            throw URLError(.badURL)
        }
        
        components.queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "season_year", value: "eq.\(seasonYear)"),
            URLQueryItem(name: "event", value: "eq.\(event.rawValue)"),
            URLQueryItem(name: "type", value: "eq.\(normalizedType)"),
            URLQueryItem(name: "order", value: "place.asc,earnings.desc")
        ]
        
        if type == .circuit {
            components.queryItems?.append(
                URLQueryItem(name: "circuit_id", value: "eq.\(circuit.id)")
                
            )
            
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.publishableKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
