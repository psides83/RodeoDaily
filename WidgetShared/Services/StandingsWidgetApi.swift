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
        
//        @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
        
//        print("event", favoriteStandingsEvent)
        
        let year = Date().yearString
        
        var dynamicUrl: URL? {
            if event == .gb {
                return URL(string: "https://us-central1-rodeo-daily.cloudfunctions.net/wpra/br/world/\(year)")
            } else if event == .lb {
                return URL(string: "https://us-central1-rodeo-daily.cloudfunctions.net/wpra/lb/world/\(year)")
            } else {
                return URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/standings?year=\(year)&type=world&id=&event=\(event.rawValue)")
            }
        }
        
        guard let url = dynamicUrl else { fatalError("Missing URL") }
        
        do {
            if event == .gb || event  == .lb {
                #if os(iOS)
                let standings = try await WpraScraper.scrape(event: event, type: .world, year: year, circuit: .columbiaRiver)
                completionHandler(standings)
                #endif
            } else {
                let standings = try await APIService.fetchStandings(from: url).data
                completionHandler(standings)
            }
        } catch {
            print("Error decoding: ", error)
        }
    }
}
