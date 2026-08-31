//
//  Daysheet.swift
//  RodeoDaily
//
//  Created by Payton Sides on 5/12/26.
//

import Foundation

struct DaysheetResponse: Codable {
    let error: String?
    let data: [String: [String: [String: DaysheetEventGroup]]]
}

struct DaysheetEventGroup: Codable {
    let rerides: [DaysheetRerideEntry]
    let events: [DaysheetEntry]

    enum CodingKeys: String, CodingKey {
        case rerides = "Rerides"
        case events = "Events"
    }
}

struct DaysheetRerideEntry: Codable, Identifiable {
    let rerideEntryId: Int
    let rodeoId: Int
    let rodeoEventId: Int
    let eventType: String
    let rerideNumber: Int?
    let brand: String?
    let stockName: String?
    let stockId: Int?
    let contractorId: Int?
    let contractorInitials: String?
    let performance: String?
    let createdOn: String?
    let modifiedOn: String?
    let eventName: String?

    var id: Int {
        rerideEntryId
    }

    enum CodingKeys: String, CodingKey {
        case rerideEntryId = "RerideEntryId"
        case rodeoId = "RodeoId"
        case rodeoEventId = "RodeoEventId"
        case eventType = "EventType"
        case rerideNumber = "RerideNumber"
        case brand = "Brand"
        case stockName = "StockName"
        case stockId = "StockId"
        case contractorId = "ContractorId"
        case contractorInitials = "ContractorInitials"
        case performance = "Performance"
        case createdOn = "CreatedOn"
        case modifiedOn = "ModifiedOn"
        case eventName = "EventName"
    }
}

struct DaysheetEntry: Codable, Identifiable {
    let eventEntryId: Int
    let rodeoId: Int
    let rodeoEventId: Int
    let goRound: Int
    let contestantId: Int?
    let teamId: Int?
    let goPosition: Int?
    let eventType: String
    let contestantNumber: Int?
    let hasTurnout: Bool

    let brand: String?
    let stockName: String?
    let stockId: Int?
    let contractorId: Int?
    let contractorInitials: String?

    let name: String
    let hometown: String?
    let performance: String
    let createdOn: String?
    let modifiedOn: String?
    let startDate: String
    let eventName: String
    let sequenceNumber: String?
    let sequence: String?

    var id: Int {
        eventEntryId
    }

    enum CodingKeys: String, CodingKey {
        case eventEntryId = "EventEntryId"
        case rodeoId = "RodeoId"
        case rodeoEventId = "RodeoEventId"
        case goRound = "GoRound"
        case contestantId = "ContestantId"
        case teamId = "TeamId"
        case goPosition = "GoPosition"
        case eventType = "EventType"
        case contestantNumber = "ContestantNumber"
        case hasTurnout = "HasTurnout"

        case brand = "Brand"
        case stockName = "StockName"
        case stockId = "StockId"
        case contractorId = "ContractorId"
        case contractorInitials = "ContractorInitials"

        case name = "Name"
        case hometown = "Hometown"
        case performance = "Performance"
        case createdOn = "CreatedOn"
        case modifiedOn = "ModifiedOn"
        case startDate = "StartDate"
        case eventName = "EventName"
        case sequenceNumber = "SequenceNumber"
        case sequence = "Sequence"
    }
}
