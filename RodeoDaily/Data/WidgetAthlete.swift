//
//  Favorite.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/14/24.
//

import AppIntents
import SwiftData

@Model
class WidgetAthlete {
    let id: UUID = UUID()
    var athleteId: Int = 0
    var name: String = ""
    var event: String = ""
    var events: [String] = []
    
    init(athleteId: Int = 0, name: String = "", event: String = "", events: [String] = []) {
        self.athleteId = athleteId
        self.name = name
        self.event = event
        self.events = events
    }
}

public struct WidgetAthleteEntity: Identifiable, AppEntity {
    public var id: UUID = UUID()
    var athleteId: Int = 0
    var name: String = ""
    var event: String = ""
    var events: [String] = []
    
    public init(athleteId: Int = 0, name: String = "", event: String = "", events: [String] = []) {
        self.athleteId = athleteId
        self.name = name
        self.event = event
        self.events = events
    }
    
    init(athlete: WidgetAthlete) {
        self.id = athlete.id
        self.athleteId = athlete.athleteId
        self.name = athlete.name
        self.event = athlete.event
        self.events = athlete.events
        
    }
        
    public static var defaultQuery: WidgetAthleteQuery {
        WidgetAthleteQuery()
    }

    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Widget Athlete")
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(event.eventDisplay)")
    }
}
