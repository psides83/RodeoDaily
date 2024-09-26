//
//  widgetAthleteQuery.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/14/24.
//

import AppIntents
import SwiftUI
import SwiftData

public struct WidgetAthleteQuery: EntityQuery {
    public init() { }
    
    public func entities(for identifiers: [WidgetAthleteEntity.ID]) async -> [WidgetAthleteEntity] {
        // Fetch the specific FavoriteAthlete entities using the identifiers
        // Example: This is a simple implementation, you'll replace it with actual data fetching.
        return await athletes().filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() async -> [WidgetAthleteEntity] {
        // Return a list of default/suggested FavoriteAthlete instances.
        return await athletes()
    }
    
    public func defaultResult() async  -> WidgetAthleteEntity? {
        await suggestedEntities().first
    }
    
    @MainActor
    func athletes() async -> [WidgetAthleteEntity] {
        guard let modelContainer = try? ModelContainer(for: WidgetAthlete.self) else {
            return []
        }
        
        let fetchDescriptor = FetchDescriptor<WidgetAthlete>()
        
        guard let athletes = try? modelContainer.mainContext.fetch(fetchDescriptor) else {
            return []
        }
        
        if athletes.count == 0 {
            return []
        }
        
        return athletes.map { athlete in
            WidgetAthleteEntity(athlete: athlete)
        }
    }
}
