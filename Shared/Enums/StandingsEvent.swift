//
//  StandingsEvent.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import AppIntents
import Foundation

public enum StandingsEvent: String, CaseIterable, Codable, Identifiable, AppEnum {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Event"
    
    public static var caseDisplayRepresentations: [StandingsEvent : DisplayRepresentation] = [
        .aa: "All Around",
        .bb: "Bareback",
        .sw: "Steer Wrestling",
        .tr: "Team Roping",
        .hd: "Heading",
        .hl: "Heeling",
        .sb: "Saddle Bronc",
        .td: "Tie-Down Roping",
        .gb: "Barrel Racing",
        .br: "Bull Riding",
        .xb: "Xtreme Bulls",
        .sr: "Steer Roping",
        .lb: "Breakaway Roping"
    ]
    
    case aa = "AA"
    case bb = "BB"
    case sw = "SW"
    case tr = "TR"
    case hd = "TRHD"
    case hl = "TRHL"
    case sb = "SB"
    case td = "TD"
    case gb = "GB"
    case br = "BR"
    case xb = "XB"
    case sr = "SR"
    case lb = "LB"
    
    var title: String {
        switch self {
        case .aa: return "All Around"
        case .bb: return "Bareback"
        case .sw: return "Steer Wrestling"
        case .tr: return "Team Roping"
        case .hd: return "Heading"
        case .hl: return "Heeling"
        case .sb: return "Saddle Bronc"
        case .td: return "Tie-Down Roping"
        case .gb: return "Barrel Racing"
        case .br: return "Bull Riding"
        case .xb: return "Xtreme Bulls"
        case .sr: return "Steer Roping"
        case .lb: return "Breakaway Roping"
        }
    }
    
    var rankingEvent: String {
        switch self {
        case .aa: return "AA"
        case .bb: return "Bareback"
        case .sw: return "Steer Wrestling"
        case .tr: return "Team Roping"
        case .hd: return "Team Roping (Headers)"
        case .hl: return "Team Roping (Heelers)"
        case .sb: return "Saddle Bronc"
        case .td: return "Tie-Down Roping"
        case .gb: return "Barrel Racing"
        case .br: return "Bull Riding"
        case .xb: return "Xtreme Bulls"
        case .sr: return "Steer Roping"
        case .lb: return "Breakaway Roping"
        }
    }
    
    var withTeamRopingConversion: String {
        switch self {
        case .aa, .bb, .sw, .sb, .td, .gb, .br, .sr, .lb, .xb:
            return self.rawValue
        case .hd, .hl, .tr:
            return "TR"
        }
    }
    
    var displayWithTeamRopingConversion: String {
        switch self {
        case .aa, .bb, .sw, .sb, .td, .gb, .br, .sr, .lb, .tr, .xb:
            return self.title
        case .hd:
            return "Team Roping (Headers)"
        case .hl:
            return "Team Roping (Heelers)"
        }
    }
    
    var isRoughStock: Bool {
        switch self {
        case .bb, .br, .sb: return true
        default: return false
        }
    }
    
    var isWPRA: Bool {
        switch self {
        case .gb, .lb: return true
        default: return false
        }
    }
    
    var hasBio: Bool {
        switch self {
        case .aa, .tr, .xb: return false
        default: return true
        }
    }
    
    var resultLabelDisplay: String {
        if isRoughStock { return "Score" }
        else { return "Time" }
    }
    
    public var id: Int {
        switch self {
        case .aa: return 12
        case .bb: return 1
        case .sb: return 2
        case .br: return 3
        case .sr: return 4
        case .td: return 5
        case .tr: return 6
        case .sw: return 7
        case .gb: return 8
        case .xb: return 9
        case .hd: return 10
        case .hl: return 11
        case .lb: return 13
        }
    }
}
