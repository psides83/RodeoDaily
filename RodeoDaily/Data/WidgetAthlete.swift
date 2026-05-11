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
    var id: UUID = UUID()
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

@Model
class FollowedAthlete {
    var id: UUID = UUID()
    var athleteId: Int = 0
    var name: String = ""
    var event: String = ""
    var payoutThreshold: Double = 10000
    var lastKnownRank: String = "Unranked"
    var lastKnownResultId: Int = 0
    var lastKnownEarnings: Double = 0
    var updatedAt: Date = Date()
    
    init(
        athleteId: Int = 0,
        name: String = "",
        event: String = "",
        payoutThreshold: Double = 10000,
        lastKnownRank: String = "Unranked",
        lastKnownResultId: Int = 0,
        lastKnownEarnings: Double = 0,
        updatedAt: Date = Date()
    ) {
        self.athleteId = athleteId
        self.name = name
        self.event = event
        self.payoutThreshold = payoutThreshold
        self.lastKnownRank = lastKnownRank
        self.lastKnownResultId = lastKnownResultId
        self.lastKnownEarnings = lastKnownEarnings
        self.updatedAt = updatedAt
    }
}

@Model
class FollowAlertEvent {
    var id: UUID = UUID()
    var athleteId: Int = 0
    var athleteName: String = ""
    var event: String = ""
    var alertType: String = ""
    var title: String = ""
    var message: String = ""
    var createdAt: Date = Date()
    var isRead: Bool = false
    
    init(
        athleteId: Int = 0,
        athleteName: String = "",
        event: String = "",
        alertType: String = "",
        title: String = "",
        message: String = "",
        createdAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.athleteId = athleteId
        self.athleteName = athleteName
        self.event = event
        self.alertType = alertType
        self.title = title
        self.message = message
        self.createdAt = createdAt
        self.isRead = isRead
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
