//
//  Video.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct VideoData: Codable {
    let total: Int
    let data: [Video]

    enum CodingKeys: String, CodingKey {
        case total, data
    }
}

// MARK: - Datum
struct Video: Codable {
    let uri, name: String
    let description: String?
    let width, height: Int
    let createdTime, modifiedTime, releaseTime, license: String
    let pictures: Pictures
    let isPlayable: Bool

    enum CodingKeys: String, CodingKey {
        case uri, name, description
        case width, height
        case createdTime = "created_time"
        case modifiedTime = "modified_time"
        case releaseTime = "release_time"
        case license, pictures
        case isPlayable = "is_playable"
    }
}

// MARK: - Pictures
struct Pictures: Codable {
    let uri: String?
    let baseLink: String
    let sizes: [Size]
    let resourceKey: String

    enum CodingKeys: String, CodingKey {
        case uri
        case baseLink = "base_link"
        case sizes
        case resourceKey = "resource_key"
    }
}

// MARK: - Size
struct Size: Codable {
    let width, height: Int
    let link: String
    let linkWithPlayButton: String?

    enum CodingKeys: String, CodingKey {
        case width, height, link
        case linkWithPlayButton = "link_with_play_button"
    }
}

