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
        guard let url = headerImageUrl else {
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
            } placeholder: {
                Image.noImage.resizable()
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
                
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
        } placeholder: {
            Image.noImage.resizable()
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var heelerImage: some View {
        guard let url = heelerImageUrl else {
            return AsyncImage(url: URL(string: "https://psides83.github.io/listJSON/noimage.png")) { image in
                image.resizable()
            } placeholder: {
                Image.noImage.resizable()
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
                
        return AsyncImage(url: URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(url)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")) {
            image in image.resizable()
        } placeholder: {
            Image.noImage.resizable()
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
