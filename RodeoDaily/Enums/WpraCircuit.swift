//
//  WpraCircuit.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/6/23.
//

import Foundation

enum WpraCircuit: String, CaseIterable {
    case badlands = "Badlands"
    case california = "California"
    case columbiaRiver = "Columbia%20River"
    case firstFrontier = "First%20Frontier"
    case greatLakes = "Great%20Lakes"
    case mapleLeaf = "Maple%20Leaf"
    case montana = "Montana"
    case mountainStates = "Mountain%20States"
    case prairie = "Prairie"
    case southeastern = "Southeastern"
    case texas = "Texas"
    case turquoise = "Turquoise"
    case wilderness = "Wilderness"
    case mexico = "Mexico"
    case brazil = "Brazil"
    
    var id: String { rawValue }
}
