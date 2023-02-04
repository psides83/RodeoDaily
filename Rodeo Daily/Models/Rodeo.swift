////
////  Rodeo.swift
////  Rodeo Daily
////
////  Created by Payton Sides on 2/2/23.
////
//
//import Foundation
//
//// MARK: - Rodeo
//struct Rodeo: Codable {
//    let error: JSONNull?
//    let data: DataClass
//}
//
//// MARK: - DataClass
//struct DataClass: Codable {
//    let events: [Event]
//    let circuit: Circuit
//    let winners: [Winner]
//    let performances: [Performance]
//    let rodeoId, rodeoNumber, seasonYear: Int
//    let name, city, stateAbbrv, startDate: String
//    let endDate: String
//    let payout: Int
//    let inProgress, isActive: Bool
//    let anniversaryNumber: Int
//    let htmlResults: String
//    let joinedYear: Int
//    let venueName: String
//    let circuitId: Int
//    let circuitIds: [Int]
//
//    enum CodingKeys: String, CodingKey {
//        case events = "Events"
//        case circuit = "Circuit"
//        case winners = "Winners"
//        case performances = "Performances"
//        case rodeoId = "RodeoId"
//        case rodeoNumber = "RodeoNumber"
//        case seasonYear = "SeasonYear"
//        case name = "Name"
//        case city = "City"
//        case stateAbbrv = "StateAbbrv"
//        case startDate = "StartDate"
//        case endDate = "EndDate"
//        case payout = "Payout"
//        case inProgress = "InProgress"
//        case isActive = "IsActive"
//        case anniversaryNumber = "AnniversaryNumber"
//        case htmlResults = "ApResults"
//        case joinedYear = "JoinedYear"
//        case venueName = "VenueName"
//        case circuitId = "CircuitId"
//        case circuitIds = "CircuitIds"
//    }
//}
//
//// MARK: - Circuit
//struct Circuit: Codable {
//    let circuitId: Int
//    let name: String
//
//    enum CodingKeys: String, CodingKey {
//        case circuitId = "CircuitId"
//        case name = "Name"
//    }
//}
//
//// MARK: - Event
//struct Event: Codable {
//    let rodeoId: Int
//    let eventType, eventName: String
//
//    enum CodingKeys: String, CodingKey {
//        case rodeoId = "RodeoId"
//        case eventType = "EventType"
//        case eventName = "EventName"
//    }
//}
//
//// MARK: - Performance
//struct Performance: Codable {
//    let name, startDate: String
//
//    enum CodingKeys: String, CodingKey {
//        case name = "Name"
//        case startDate = "StartDate"
//    }
//}
//
//// MARK: - Winner
//struct Winner: Codable {
//    let rodeoId: Int
//    let contestant: Contestant
//    let teamId: Int
//    let eventType, startDate: String
//    let score, time, payoff: Double
//
//    enum CodingKeys: String, CodingKey {
//        case rodeoId = "RodeoId"
//        case contestant = "Contestant"
//        case teamId = "TeamId"
//        case eventType = "EventType"
//        case startDate = "StartDate"
//        case score = "Score"
//        case time = "Time"
//        case payoff = "Payoff"
//    }
//}
//
//// MARK: - Contestant
//struct Contestant: Codable {
//    let contestantId: Int
//    let firstName, lastName: String
//    let nickName: String?
//    let hometown: String
//    let photoUrl: String?
//    let featured: Bool
//    let birthDate: String
//    let age, totalEarnings, yearEarnings: Int
//    let worldTitles, nfrQualifications: Int?
//    let dateJoined: String
//    let eventTypes, biographyText: JSONNull?
//    let videoHighlights: String?
//
//    enum CodingKeys: String, CodingKey {
//        case contestantId = "ContestantId"
//        case firstName = "FirstName"
//        case lastName = "LastName"
//        case nickName = "NickName"
//        case hometown = "Hometown"
//        case photoUrl = "PhotoUrl"
//        case featured = "Featured"
//        case birthDate = "BirthDate"
//        case age = "Age"
//        case totalEarnings = "TotalEarnings"
//        case yearEarnings = "YearEarnings"
//        case worldTitles = "WorldTitles"
//        case nfrQualifications = "NFRQualifications"
//        case dateJoined = "DateJoined"
//        case eventTypes = "EventTypes"
//        case biographyText = "BiographyText"
//        case videoHighlights = "VideoHighlights"
//    }
//}
//
