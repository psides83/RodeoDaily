//
//  Circuit.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/5/23.
//

import Foundation

enum Circuit: CaseIterable, Identifiable {
    case columbiaRiver,
         california,
         wilderness,
         montana,
         mountainStates,
         turquoise,
         texas,
         prairie,
         greatLakes,
         southeastern,
         firstFrontier,
         mapleLeaf,
         badlands,
         mexico,
         brazil
    
    var id: Int {
        switch self {
        case .columbiaRiver: return 1
        case .california: return 2
        case .wilderness: return 3
        case .montana: return 4
        case .mountainStates: return 5
        case .turquoise: return 6
        case .texas: return 7
        case .prairie: return 8
        case .greatLakes: return 9
        case .southeastern: return 10
        case .firstFrontier: return 11
        case .mapleLeaf: return 12
        case .badlands: return 13
        case .mexico: return 14
        case .brazil: return 15
        }
    }
    
    var title: String {
        switch self {
        case .columbiaRiver: return "Columbia River"
        case .california: return "California"
        case .wilderness: return "Wilderness"
        case .montana: return "Montana"
        case .mountainStates: return "Mountain States"
        case .turquoise: return "Turquoise"
        case .texas: return "Texas"
        case .prairie: return "Prairie"
        case .greatLakes: return "Great Lakes"
        case .southeastern: return "Southeastern"
        case .firstFrontier: return "First Frontier"
        case .mapleLeaf: return "Maple Leaf"
        case .badlands: return "Badlands"
        case .mexico: return "Mexico"
        case .brazil: return "Brazil"
        }
    }
    
    var convertToWpra: String {
        switch self {
        case .badlands: return "badlands"
        case .california: return "california"
        case .columbiaRiver: return "columbia%20river"
        case .firstFrontier: return "first%20frontier"
        case .greatLakes: return "great%20lakes"
        case .mapleLeaf: return "maple%20leaf"
        case .montana: return "montana"
        case .mountainStates: return "mountain%20states"
        case .prairie: return "prairie"
        case .southeastern: return "southeastern"
        case .texas: return "texas"
        case .turquoise: return "turquoise"
        case .wilderness: return "wilderness"
        case .mexico: return "mexico"
        case .brazil: return "brazil"
        }
    }
    
    var convertToGit: String {
        switch self {
        case .badlands: return "BADLANDS"
        case .california: return "CALIFORNIA"
        case .columbiaRiver: return "COLUMBIA_RIVER"
        case .firstFrontier: return "FIRST_FRONTIER"
        case .greatLakes: return "GREAT_LAKES"
        case .mapleLeaf: return "MAPLE_LEAF"
        case .montana: return "MONTANA"
        case .mountainStates: return "MOUNTAIN_STATES"
        case .prairie: return "PRARIE"
        case .southeastern: return "SOUTHEASTERN"
        case .texas: return "TEXAS"
        case .turquoise: return "TURQUOISE"
        case .wilderness: return "WILDERNESS"
        case .mexico: return "MEXICO"
        case .brazil: return "BRAZIL"
        }
    }
}
