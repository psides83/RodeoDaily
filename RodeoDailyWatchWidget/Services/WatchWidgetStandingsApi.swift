//
//  StandingsApi.swift
//  RodeoDailyWatchWidgetExtension
//
//  Created by Payton Sides on 2/21/23.
//

import Foundation
import SwiftUI

class WatchStandingsWidgetApi: ObservableObject {
    
    func getStandings(event: String, completionHandler: @escaping ([Position]) -> Void) async {
        
//        @AppStorage("standingsWatchWidgetEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchWidgetEvent: StandingsEvent = .aa
        
        var covertedEvent: StandingsEvent {
            switch event {
            case "AA": return .aa
            case "BB": return .bb
            case "SW": return .sw
            case "HD": return .hd
            case "HL": return .hl
            case "SB": return .sb
            case "TD": return .td
            case "GB": return .gb
            case "BR": return .br
            case "LB": return .lb
            default: return .aa
            }
        }
        
        print("event", covertedEvent)
        
        let year = Date().yearString
        
        var dynamicUrl: URL? {
            return URL(string: "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/standings?year=\(year)&type=world&id=&event=\(covertedEvent.rawValue)")
        }
        
        guard let url = dynamicUrl else { fatalError("Missing URL") }
                
        do {
            if covertedEvent == .gb || covertedEvent  == .lb {
                let standings = try await WpraScraper.scrape(event: covertedEvent, type: .world, year: year, circuit: .columbiaRiver)
                completionHandler(standings)
            } else {
                let standings = try await APIService.fetchStandings(from: url).data
                completionHandler(standings)
            }
        } catch {
            print("Error decoding: ", error)
        }
    }
}
