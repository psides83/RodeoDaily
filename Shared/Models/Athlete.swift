//
//  AthleteStandings.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import Foundation
import SwiftUI

struct Athlete: Codable, Identifiable {
    let id: Int
    let firstName: String
    let nickName: String?
    let lastName: String
    let hometown: String
    let imageUrl: String?
    var event: String
    let events: [String]
    
    var name: String {
        let name = PersonNameComponents(givenName: firstName, familyName: lastName, nickname: nickName)
        
        return name.formatted(.name(style: .medium))
    }
    
    var image: some View {
        AthleteImageView(preferredImageUrl: imageUrl) {
            Color.gray.opacity(0.5)
        }
    }

}
