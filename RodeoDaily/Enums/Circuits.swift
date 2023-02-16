//
//  Circuits.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/5/23.
//

import Foundation

enum Circuits: CaseIterable, Identifiable {
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
        case .badlands: return "Badlands"
        case .california: return "California"
        case .columbiaRiver: return "Columbia%20River"
        case .firstFrontier: return "First%20Frontier"
        case .greatLakes: return "Great%20Lakes"
        case .mapleLeaf: return "Maple%20Leaf"
        case .montana: return "Montana"
        case .mountainStates: return "Mountain%20States"
        case .prairie: return "Prairie"
        case .southeastern: return "Southeastern"
        case .texas: return "Texas"
        case .turquoise: return "Turquoise"
        case .wilderness: return "Wilderness"
        case .mexico: return "Mexico"
        case .brazil: return "Brazil"
        }
    }
}
