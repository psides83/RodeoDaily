//
//  FavoriteAthlete.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import AppIntents
//import Foundation
import SwiftUI
import WidgetKit

public struct FavoriteAthlete: Codable, Identifiable, Equatable, AppEntity {
    public let id: Int
    let name: String
    var event: StandingsEvent
    let teamRopingEvent: StandingsEvent?
    let events: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, event, teamRopingEvent, events
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
        self.teamRopingEvent = try values.decode(StandingsEvent.self, forKey: .teamRopingEvent)
        self.events = try values.decode([String].self, forKey: .events)
    }
    
    public init(
        id: Int,
        name: String,
        event: StandingsEvent,
        teamRopingEvent: StandingsEvent?,
        events: [String]
    ) {
        self.id = id
        self.name = name
        self.event = event
        self.teamRopingEvent = teamRopingEvent
        self.events = events
    }
    
    // This replaces `defaultQuery` with an actual query type.
       public static var defaultQuery: FavoriteAthleteQuery {
           return FavoriteAthleteQuery()
       }
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Widget Athlete")
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(event.title)")
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
        try container.encode(self?.events, forKey: .events)
    }
}

// A query to return a list of FavoriteAthlete entities
public struct FavoriteAthleteQuery: EntityQuery {
    public init() { }
    
//    var favoriteAthletes = [FavoriteAthlete]()

    @AppStorage(
        "favoriteAthletes",
        store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")
    ) var favoriteAthletesData: Data = Data()
    
    func favoriteAthletes() -> [FavoriteAthlete] {
        let favoriteAthletes = [FavoriteAthlete]()

        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode([FavoriteAthlete].self, from: favoriteAthletesData) {
            return decodedData
        }
        
        return favoriteAthletes
    }
    
    public func entities(for identifiers: [FavoriteAthlete.ID]) -> [FavoriteAthlete] {
        // Fetch the specific FavoriteAthlete entities using the identifiers
        // Example: This is a simple implementation, you'll replace it with actual data fetching.
        return favoriteAthletes().filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() -> [FavoriteAthlete] {
        // Return a list of default/suggested FavoriteAthlete instances.
        return favoriteAthletes()
    }
    
    public func defaultResult() -> FavoriteAthlete? {
        suggestedEntities().first
    }
}
