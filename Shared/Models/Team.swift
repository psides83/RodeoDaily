//
//  Team.swift
//  RodeoDaily
//
//  Created by Payton Sides on 3/1/23.
//

import Foundation
import SwiftUI

struct Team: Identifiable, Hashable {
    let id: Int
    let headerId: Int
    let headerName: String
    let heelerId: Int
    let heelerName: String
    let roundLabel, place: String
    let headerHometown, heelerHometown: String
    let headerImageUrl, heelerImageUrl: String?
    let payoff, time: String
    let round: Int
    
    var headerImage: some View {
        AthleteImageView(preferredImageUrl: headerImageUrl)
    }
    
    var heelerImage: some View {
        AthleteImageView(preferredImageUrl: heelerImageUrl)
    }

}
