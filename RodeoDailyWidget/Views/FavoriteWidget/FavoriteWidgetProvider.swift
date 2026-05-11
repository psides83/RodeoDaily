//
//  FAvoriteWidgetProvider.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import SwiftUI
import WidgetKit

struct FavoriteProvider: AppIntentTimelineProvider {
    typealias Intent = FavoriteWidgetIntent
    
    public typealias Entry = FavoriteWidgetEntry
    
    let sampleData = WidgetSampleData().favoriteSampleData
    
    func placeholder(in context: Context) -> FavoriteWidgetEntry {
        Entry(date: Date(), bio: sampleData, event: "TD")
    }
    
    func snapshot(for configuration: FavoriteWidgetIntent, in context: Context) async -> FavoriteWidgetEntry {
        guard let athlete = configuration.athlete else {
            return Entry(date: Date(), bio: sampleData, event: "TD")
        }
        
        var bioData: BioData?
        
        await FavoriteWidgetApi().loadBio(for: athlete.athleteId) { bio in
            bioData = bio
        }
        
        if let data = bioData {
            return Entry(date: Date(), bio: data, event: athlete.event)
        } else {
            return Entry(date: Date(), bio: sampleData, event: "TD")
        }
    }
    
    func timeline(for configuration: FavoriteWidgetIntent, in context: Context) async -> Timeline<FavoriteWidgetEntry> {
        guard let athlete = configuration.athlete else {
            return Timeline(
                entries: [Entry(date: Date(), bio: sampleData, event: "TD")],
                policy: .after(.now.advanced(by: 60 * 60 * 12))
            )
        }
        
        var bioData: BioData?
        
        var entries: [Entry] = []
        
        await FavoriteWidgetApi().loadBio(for: athlete.athleteId) { bio in
            bioData = bio
            
            if let data = bioData {
                entries.append(Entry(date: Date(), bio: data, event: athlete.event))
            }
        }
        
        if entries.isEmpty {
            entries.append(Entry(date: Date(), bio: sampleData, event: "TD"))
        }
        
        return Timeline(entries: entries, policy: .after(.now.advanced(by: 60 * 60 * 12)))
    }
}
