//
//  Tour.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/5/23.
//

import Foundation

enum Tour: String, CaseIterable, Identifiable {
    case xBulls,
         xBroncs,
         legacySteerRoping,
         playoffSeries,
         none
    
    var id: Int {
        switch self {
        case .xBulls: return 4
        case .xBroncs: return 15
        case .legacySteerRoping: return 16
        case .playoffSeries: return 17
        case .none: return 99
        }
    }
    
    var title: String {
        switch self {
        case .xBulls: return "Xtreme Bulls"
        case .xBroncs: return "Xtreme Broncs"
        case .legacySteerRoping: return "Legacy Steer Roping"
        case .playoffSeries: return NSLocalizedString("Playoff Series", comment: "")
        case .none: return ""
        }
    }
}
