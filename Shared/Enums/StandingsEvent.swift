//
//  StandingsEvent.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import AppIntents
import Foundation

enum StandingsEvent: String, CaseIterable, Codable, Identifiable, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Event"
    
    static var caseDisplayRepresentations: [StandingsEvent : DisplayRepresentation] = [
        .aa: "All Around",
        .bb: "Bareback",
        .sw: "Steer Wrestling",
        .hd: "Heading",
        .hl: "Heeling",
        .sb: "Saddle Bronc",
        .td: "Tie-Down Roping",
        .gb: "Barrel Racing",
        .br: "Bull Riding",
        .sr: "Steer Roping",
        .lb: "Breakaway Roping"
    ]
    
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
    
    var isRoughStock: Bool {
        switch self {
        case .bb, .br, .sb: return true
        default: return false
        }
    }
    
    var hasBio: Bool {
        switch self {
        case .aa, .gb, .lb: return false
        default: return true
        }
    }
    
    var resultLabelDisplay: String {
        if isRoughStock { return "Score" }
        else { return "Time" }
    }
    
    var id: String { rawValue }
}
