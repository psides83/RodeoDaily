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
    let image315Url: String?
    let photoUrl: String?
    let birthDate: String

    enum CodingKeys: String, CodingKey {
        case contestantId = "ContestantId"
        case firstName = "FirstName"
        case lastName = "LastName"
        case nickName = "NickName"
        case hometown = "Hometown"
        case image315Url = "image_315_url"
        case photoUrl = "PhotoUrl"
        case birthDate = "BirthDate"
    }
    
    var name: String {
        let name = PersonNameComponents(givenName: firstName, familyName: lastName, nickname: nickName)
        
        return name.formatted(.name(style: .medium))
    }
    
    var image: some View {
        AthleteImageView(preferredImageUrl: image315Url, fallbackImageUrl: photoUrl) {
            Color.gray.opacity(0.5)
        }
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
struct SearchResultElement: Codable, Identifiable {
    let term, type: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case term = "Term"
        case type = "Type"
        case id = "Id"
    }
}
