//
//  NFRStandings.swift
//  RodeoDaily
//

import Foundation

struct NFRStandingsResponse: Decodable {
    let error: String?
    let data: NFRStandingsPayload
}

struct NFRStandingsPayload: Decodable {
    let data: [NFRContestant]
}

struct NFRRoundResult: Identifiable, Equatable {
    let round: Int
    let score: String?
    let place: Int?
    let currentRound: Int
    let isRoughStock: Bool

    var id: Int { round }
    var isPending: Bool { round > currentRound }
    var hasResult: Bool {
        guard let score, let numericScore = Double(score) else { return false }
        return numericScore != 0
    }

    var displayValue: String {
        if isPending {
            return NSLocalizedString("Pending", comment: "")
        }

        guard hasResult, let score else {
            return isRoughStock ? "NS" : "NT"
        }

        if let place {
            return "\(place.ordinal) - \(score)"
        }

        return score
    }
}

struct NFRContestant: Decodable, Identifiable {
    let id: Int
    let worldPlace: Int
    let currentRound: Int
    let contestantId: Int
    let averagePlace: Int
    let averageScore: String
    let eventType: String
    let sidearmPhotoPath: String?
    let firstName: String
    let lastName: String
    let rounds: [NFRRoundResult]

    var name: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var averageDisplayValue: String {
        String(
            format: NSLocalizedString("%@ in the AVG with %@ on %d", comment: "NFR average sentence with average place, aggregate score/time, and qualified round count"),
            averagePlace.ordinal,
            averageScore,
            qualifiedRoundCount
        )
    }

    var qualifiedRoundCount: Int {
        rounds.filter(\.hasResult).count
    }

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case worldPlace = "WorldPlace"
        case currentRound = "CurrentGo"
        case contestantId = "ContestantId"
        case averagePlace = "AveragePlace"
        case averageScore = "AverageScore"
        case eventType = "EventType"
        case sidearmPhotoPath = "SidearmPhotoUrl"
        case firstName = "FirstName"
        case lastName = "LastName"
        case go1Result = "Go1Result"
        case go1Place = "Go1Place"
        case go2Result = "Go2Result"
        case go2Place = "Go2Place"
        case go3Result = "Go3Result"
        case go3Place = "Go3Place"
        case go4Result = "Go4Result"
        case go4Place = "Go4Place"
        case go5Result = "Go5Result"
        case go5Place = "Go5Place"
        case go6Result = "Go6Result"
        case go6Place = "Go6Place"
        case go7Result = "Go7Result"
        case go7Place = "Go7Place"
        case go8Result = "Go8Result"
        case go8Place = "Go8Place"
        case go9Result = "Go9Result"
        case go9Place = "Go9Place"
        case go10Result = "Go10Result"
        case go10Place = "Go10Place"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        worldPlace = try container.decode(Int.self, forKey: .worldPlace)
        currentRound = try container.decode(Int.self, forKey: .currentRound)
        contestantId = try container.decode(Int.self, forKey: .contestantId)
        averagePlace = try container.decode(Int.self, forKey: .averagePlace)
        averageScore = try container.decode(String.self, forKey: .averageScore)
        eventType = try container.decode(String.self, forKey: .eventType)
        sidearmPhotoPath = try container.decodeIfPresent(String.self, forKey: .sidearmPhotoPath)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)

        let isRoughStock = Self.isRoughStockEvent(eventType)
        rounds = [
            Self.makeRound(1, resultKey: .go1Result, placeKey: .go1Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(2, resultKey: .go2Result, placeKey: .go2Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(3, resultKey: .go3Result, placeKey: .go3Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(4, resultKey: .go4Result, placeKey: .go4Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(5, resultKey: .go5Result, placeKey: .go5Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(6, resultKey: .go6Result, placeKey: .go6Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(7, resultKey: .go7Result, placeKey: .go7Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(8, resultKey: .go8Result, placeKey: .go8Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(9, resultKey: .go9Result, placeKey: .go9Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container),
            Self.makeRound(10, resultKey: .go10Result, placeKey: .go10Place, currentRound: currentRound, isRoughStock: isRoughStock, container: container)
        ]
    }

    private static func makeRound(
        _ round: Int,
        resultKey: CodingKeys,
        placeKey: CodingKeys,
        currentRound: Int,
        isRoughStock: Bool,
        container: KeyedDecodingContainer<CodingKeys>
    ) -> NFRRoundResult {
        let rawScore = (try? container.decode(String.self, forKey: resultKey))?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let score = rawScore?.isEmpty == false ? rawScore : nil
        let rawPlace = (try? container.decode(String.self, forKey: placeKey))?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let place = rawPlace.flatMap(Int.init)

        return NFRRoundResult(
            round: round,
            score: score,
            place: place,
            currentRound: currentRound,
            isRoughStock: isRoughStock
        )
    }

    private static func isRoughStockEvent(_ eventType: String) -> Bool {
        ["BB", "SB", "BR"].contains(eventType)
    }
}

private extension Int {
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
