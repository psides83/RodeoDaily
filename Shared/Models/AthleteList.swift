//
//  AutoComplete.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/12/24.
//

import Foundation
import SwiftUI

// MARK: - AthleteList
struct AthleteList: Codable {
    let error: JSONNull?
    let data: [AthleteData]
}

// MARK: - Datum
struct AthleteData: Codable {
    let contestantId: Int
    let firstName, lastName, nickName, hometown: String
    let photoUrl: String?
    let birthDate: String

    enum CodingKeys: String, CodingKey {
        case contestantId = "ContestantId"
        case firstName = "FirstName"
        case lastName = "LastName"
        case nickName = "NickName"
        case hometown = "Hometown"
        case photoUrl = "PhotoUrl"
        case birthDate = "BirthDate"
    }
    
    var name: String {
        let name = PersonNameComponents(givenName: firstName, familyName: lastName, nickname: nickName)
        
        return name.formatted(.name(style: .medium))
    }
    
    var image: some View {
        guard let url = photoUrl else {
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

// MARK: - Athlete Search Suggestions
struct SearchSuggestion: Codable {
    let error: JSONNull?
    let data: [String: SuggestionData]
}

// MARK: - DatumValue
struct SuggestionData: Codable {
    let type: String
    let data: [SearchResultElement]
    let count: Int
}

// MARK: - DatumElement
struct SearchResultElement: Codable {
    let term, type: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case term = "Term"
        case type = "Type"
        case id = "Id"
    }
}
