//
//  RodeoResults.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation

// MARK: - Results
struct RodeoResults: Codable {
    let error: JSONNull?
    let data: [Datum]?
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int
    let name: String
    let htmlResults, city, state, venueName: String
    let events: Events?

    enum CodingKeys: String, CodingKey {
        case id = "RodeoId"
        case name = "RodeoName"
        case htmlResults = "ApResults"
        case city = "City"
        case state = "State"
        case venueName = "VenueName"
        case events = "Events"
    }
}

// MARK: - Events
struct Events: Codable {
    let bb, sw, tr, sb, td, gb, br, sr, lb: [String: [Round]]?

    enum CodingKeys: String, CodingKey, CaseIterable, Codable {
        case bb = "BB"
        case sw = "SW"
        case tr = "TR"
        case sb = "SB"
        case td = "TD"
        case gb = "GB"
        case br = "BR"
        case sr = "SR"
        case lb = "LB"
        
        var title: String {
            switch self {
            case .bb: return "Bareback"
            case .sw: return "Steer Wrestling"
            case .tr: return "Team Roping"
            case .sb: return "Saddle Bronc"
            case .td: return "Tie-Down Roping"
            case .gb: return "Barrel Racing"
            case .br: return "Bull Riding"
            case .sr: return "Steer Roping"
            case .lb: return "Breakaway Roping"
            }
        }
        
        var isRoughStock: Bool {
            switch self {
            case .bb, .br, .sb: return true
            default: return false
            }
        }
        
        var id: String { rawValue }
    }
}

// MARK: - Round
struct Round: Codable {
    let eventType: String
    let payoff: Double
    let place: Int
    let score: Double
    let teamId, stockId, goRound: Int
    let goRoundLabel: String
    let time: Double
    let numberScores: Int?
    let rideTimestamp: String?
    let contestant: [Contestant]
    let stock: [Stock]?

    enum CodingKeys: String, CodingKey {
        case eventType = "EventType"
        case payoff = "Payoff"
        case place = "Place"
        case score = "Score"
        case teamId = "TeamId"
        case stockId = "StockId"
        case goRound = "GoRound"
        case goRoundLabel = "GoRoundLabel"
        case time = "Time"
        case numberScores = "NumberScores"
        case rideTimestamp = "RideTimestamp"
        case contestant = "Contestant"
        case stock = "Stock"
    }
}

// MARK: - Contestant
struct Contestant: Codable {
    let id: Int
    let firstName, lastName: String
    let hometown, nickName, imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "ContestantId"
        case firstName = "FirstName"
        case lastName = "LastName"
        case nickName = "NickName"
        case hometown = "Hometown"
        case image315Url = "image_315_url"
        case image315PascalUrl = "Image315Url"
        case imageUrl = "PhotoUrl"
        case photoSnakeUrl = "photo_url"
        case sidearmPhotoUrl = "SidearmPhotoUrl"
        case sidearmPhotoSnakeUrl = "sidearm_photo_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        hometown = try container.decodeIfPresent(String.self, forKey: .hometown)
        imageUrl = try Contestant.decodeFirstImageUrl(from: container)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encodeIfPresent(nickName, forKey: .nickName)
        try container.encodeIfPresent(hometown, forKey: .hometown)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
    }
}

private extension Contestant {
    static func decodeFirstImageUrl(from container: KeyedDecodingContainer<CodingKeys>) throws -> String? {
        for key in imageUrlKeys {
            guard let imageUrl = try container.decodeIfPresent(String.self, forKey: key)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !imageUrl.isEmpty
            else {
                continue
            }

            return imageUrl
        }

        return nil
    }

    static let imageUrlKeys: [CodingKeys] = [
        .image315Url,
        .image315PascalUrl,
        .imageUrl,
        .photoSnakeUrl,
        .sidearmPhotoUrl,
        .sidearmPhotoSnakeUrl
    ]
}

extension Contestant {
    var name: String {
        guard nickName != "" else { return "\(firstName) \(lastName)" }
        
        return "\(nickName ?? firstName) \(lastName)"
    }
}

enum LeftStockScore: Codable {
    case double(Double)
    case integer(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(LeftStockScore.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for LeftStockScore"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .double(let x):
                try container.encode(x)
            case .integer(let x):
                try container.encode(x)
        }
    }
}

// MARK: - Stock
struct Stock: Codable {
    let id: Int
    let name, brand: String
    let eventTypes: [String]
    let contractor: Contractor

    enum CodingKeys: String, CodingKey {
        case id = "StockId"
        case name = "Name"
        case brand = "Brand"
        case eventTypes = "EventTypes"
        case contractor = "Contractor"
    }
}

// MARK: - Contractor
struct Contractor: Codable {
    let id: Int
    let name, initials, city, state: String

    enum CodingKeys: String, CodingKey {
        case id = "ContractorId"
        case name = "Name"
        case initials = "Initials"
        case city = "City"
        case state = "State"
    }
}
