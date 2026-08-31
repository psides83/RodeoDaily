//
//  Tour.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/5/23.
//

import Foundation

enum StandingType: String, CaseIterable {
    case world = "world"
    case playoff = "playoffSeries"
    case rookie = "rookie"
    case circuit = "circuit"
    case xBulls = "xtremeBulls"
    case xBroncs = "xtremeBroncs"
    case permit = "permit"
    case legacySteerRoping = "legacySteerRoping"

    static var filterOrder: [StandingType] {
        [
            .world,
            .playoff,
            .rookie,
            .circuit,
            .xBulls,
            .xBroncs,
            .permit,
            .legacySteerRoping
        ]
    }
    
    var title: String {
        switch self {
        case .world: return NSLocalizedString("World Standings", comment: "")
        case .xBulls: return "Xtreme Bulls"
        case .xBroncs: return "Xtreme Broncs"
        case .legacySteerRoping: return "Legacy Steer Roping"
        case .playoff: return NSLocalizedString("Playoff Series", comment: "")
        case .circuit: return NSLocalizedString("Circuit", comment: "")
        case .rookie: return NSLocalizedString("Rookie", comment: "")
        case .permit: return NSLocalizedString("Permit", comment: "Permit")
        }
    }
    
    var hasEvents: Bool {
        switch self {
        case .xBulls, .xBroncs, .legacySteerRoping: return false
        default: return true
        }
    }
    
    var isNotSingleEvent: Bool {
        switch self {
            case .xBulls, .xBroncs, .legacySteerRoping: return false
            default: return true
        }
    }
    
    var id: String { rawValue }
}
