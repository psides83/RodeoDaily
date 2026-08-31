//
//  WidgetStandingsApi.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 2/4/23.
//

import Foundation
import SwiftUI

class StandingsWidgetApi: ObservableObject {
    
    func getStandings(event: StandingsEvent, completionHandler: @escaping ([Position]) -> Void) async {
        do {
            let standings = try await StandingsService.fetchStandings(
                event: event,
                selectedYear: StandingsService.defaultWidgetSeasonYear()
            )
            completionHandler(standings)
        } catch {
            print("[StandingsWidget] Failed loading \(event.rawValue): \(error.localizedDescription)")
            completionHandler([])
        }
    }
}
