//
//  AthleteStandings.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import Foundation
import SwiftUI

struct Athlete: Identifiable {
    let id: Int
    let firstName: String
    let nickName: String?
    let lastName: String
    let hometown: String
    let imageUrl: String?
}

extension Athlete {
    var name: String {
        return "\(nickName ?? firstName) \(lastName)"
    }
    
    var image: some View {
        guard let url = imageUrl else {
            
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
                
            } placeholder: {
                Color.gray.opacity(0.5)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
                
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
            
        } placeholder: {
            Color.gray.opacity(0.5)
            
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
