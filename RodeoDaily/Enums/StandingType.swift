//
//  Tour.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/5/23.
//

import Foundation

enum StandingType: String, CaseIterable {
    case world = "world"
    case xBulls = "xtremeBulls"
    case xBroncs = "xtremeBroncs"
    case legacySteerRoping = "legacySteerRoping"
    case circuit = "circuit"
    case rookie = "rookie"
    case permit = "permit"
    
    var title: String {
        switch self {
        case .world: return "World Standings"
        case .xBulls: return "Xtreme Bulls"
        case .xBroncs: return "Xtreme Broncs"
        case .legacySteerRoping: return "Legacy Steer Roping"
        case .circuit: return "Circuit"
        case .rookie: return "Rookie"
        case .permit: return "Permit"
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
