//
//  widgetAthleteQuery.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/14/24.
//

import AppIntents
import Foundation
import SwiftData
import SwiftUI

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
        let schema = Schema([WidgetAthlete.self, FollowedAthlete.self, FollowAlertEvent.self])
        let configuration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        let modelContainer: ModelContainer

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("[WidgetAthleteQuery] Unable to open favorite athlete store: \(error.localizedDescription)")
            return []
        }
        
        let athletes: [WidgetAthlete]

        do {
            athletes = try modelContainer.mainContext.fetch(FetchDescriptor<WidgetAthlete>())
        } catch {
            print("[WidgetAthleteQuery] Unable to fetch favorite athletes: \(error.localizedDescription)")
            return []
        }

        return athletes.sorted(by: favoriteOrder).map { athlete in
            WidgetAthleteEntity(athlete: athlete)
        }
    }

    private func favoriteOrder(_ lhs: WidgetAthlete, _ rhs: WidgetAthlete) -> Bool {
        switch (lhs.sortOrder, rhs.sortOrder) {
        case let (left?, right?) where left != right:
            return left < right
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private var sharedStoreURL: URL {
        let appGroupId = "group.PaytonSides.RodeoDaily"
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else {
            return URL.documentsDirectory.appending(path: "default.store")
        }

        let storeDirectory = groupURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        try? FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
        return storeDirectory.appendingPathComponent("default.store")
    }
}
