//
//  FavoriteAthlete.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

public struct FavoriteAthlete: Codable, Identifiable, Equatable {
    public let id: Int
    let name: String
    let event: StandingsEvent
    
    enum CodingKeys: String, CodingKey {
        case id, name, event
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            id = try Int(values.decode(Int.self, forKey: .id))
        } catch DecodingError.typeMismatch {
            id = try Int(values.decode(String.self, forKey: .id)) ?? 0
        }
        self.name = try values.decode(String.self, forKey: .name)
        self.event = try values.decode(StandingsEvent.self, forKey: .event)
    }
    
    init(id: Int, name: String, event: StandingsEvent) {
        self.id = id
        self.name = name
        self.event = event
    }
}

extension Optional: RawRepresentable where Wrapped == FavoriteAthlete {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(FavoriteAthlete.self, from: data)
        else {
            return nil
        }
        
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        
        return result
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FavoriteAthlete.CodingKeys.self)
        try container.encode(self?.id, forKey: .id)
        try container.encode(self?.name, forKey: .name)
        try container.encode(self?.event, forKey: .event)
    }
}
