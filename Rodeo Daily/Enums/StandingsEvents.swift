//
//  StandingsEvents.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import Foundation

enum StandingsEvents: String, CaseIterable {
    case aa = "AA"
    case bb = "BB"
    case sw = "SW"
    case hd = "TRHD"
    case hl = "TRHL"
    case sb = "SB"
    case td = "TD"
    case gb = "GB"
    case br = "BR"
    case sr = "SR"
    case lb = "LB"
    
    var title: String {
        switch self {
        case .aa: return "All Around"
        case .bb: return "Bareback"
        case .sw: return "Steer Wrestling"
        case .hd: return "Heading"
        case .hl: return "Heeling"
        case .sb: return "Saddle Bronc"
        case .td: return "Tie-Down Roping"
        case .gb: return "Barrel Racing"
        case .br: return "Bull Riding"
        case .sr: return "Steer Roping"
        case .lb: return "Breakaway Roping"
        }
    }
}

extension StandingsEvents: Identifiable {
    var id: String { rawValue }
}
