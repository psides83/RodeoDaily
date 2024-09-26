//
//  FavoriteWidgetIntent.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/13/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct FavoriteWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Favorite"
    
    static var description = IntentDescription("Selects the favorite athlete to display in the widget.")
    
    @Parameter(title: "Athlete") var athlete: WidgetAthleteEntity
    
    init() {}
}
