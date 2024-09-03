//
//  Cowboy.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation

// MARK: - Cowboy
struct Bio: Codable {
    let error: JSONNull?
    let data: BioData
}

// MARK: - BioData
struct BioData: Codable {
    var results: [BioResult] = []
    var averages: [BioAverage] = []
    var career: [Career] = []
    var rankings: [Ranking] = []
    var earnings: [String: [Earning]] = [:]
    var contestantId: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var nickName: String?
    var hometown: String = ""
    var imageUrl: String?
    var featured: Bool = false
    var birthDate: String = ""
    var age: Int?
    var totalEarnings: Double?
    var yearEarnings: Int?
    var worldTitles: Int?
    var nfrQualifications: Int?
    var dateJoined: String = ""
    var eventTypes: [String]?
    var biographyText: String = ""
    var videoHighlights: String?

    enum CodingKeys: String, CodingKey {
        case results = "Results"
        case averages = "Averages"
        case career = "Career"
        case rankings = "Rankings"
        case earnings = "Earnings"
        case contestantId = "ContestantId"
        case firstName = "FirstName"
        case lastName = "LastName"
        case nickName = "NickName"
        case hometown = "Hometown"
        case imageUrl = "PhotoUrl"
        case featured = "Featured"
        case birthDate = "BirthDate"
        case age = "Age"
        case totalEarnings = "TotalEarnings"
        case yearEarnings = "YearEarnings"
        case worldTitles = "WorldTitles"
        case nfrQualifications = "NFRQualifications"
        case dateJoined = "DateJoined"
        case eventTypes = "EventTypes"
        case biographyText = "BiographyText"
        case videoHighlights = "VideoHighlights"
    }
}

// MARK: - Career
struct Career: Codable {
    let season: Int
    let eventType: String
    let earnings: Double
    let worldTitles: Int
    let nfrQualified: Bool
//    let ridingStatistics: JSONNull?
    let timedStatistics: TimedStatistics?

    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case eventType = "EventType"
        case earnings = "Earnings"
        case worldTitles = "WorldTitles"
        case nfrQualified = "NFRQualified"
//        case ridingStatistics = "RidingStatistics"
        case timedStatistics = "TimedStatistics"
    }
}

// MARK: - TimedStatistics
struct TimedStatistics: Codable {
    let season: Int
    let eventType: String
    let eventId, attempts, qualifiedTimes: Int
    let timedPercent, avgScore: Double
    let numberExcellentTimes, numberGoodTimes: Int
    let numberExcellentTimesPercent, numberGoodTimesPercent: Double
    let goRoundWins, goRoundSecondWins, goRoundThirdWins, goRoundFourthWins: Int
    let goRoundFifthWins, goRoundSixthWins: Int
    let topSixFinishPercent: Double
    let barrierPenalties: Int

    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case eventType = "EventType"
        case eventId = "EventId"
        case attempts = "Attempts"
        case qualifiedTimes = "QualifiedTimes"
        case timedPercent = "TimedPercent"
        case avgScore = "AvgScore"
        case numberExcellentTimes = "NumberExcellentTimes"
        case numberGoodTimes = "NumberGoodTimes"
        case numberExcellentTimesPercent = "NumberExcellentTimesPercent"
        case numberGoodTimesPercent = "NumberGoodTimesPercent"
        case goRoundWins = "GoRoundWins"
        case goRoundSecondWins = "GoRoundSecondWins"
        case goRoundThirdWins = "GoRoundThirdWins"
        case goRoundFourthWins = "GoRoundFourthWins"
        case goRoundFifthWins = "GoRoundFifthWins"
        case goRoundSixthWins = "GoRoundSixthWins"
        case topSixFinishPercent = "TopSixFinishPercent"
        case barrierPenalties = "BarrierPenalties"
    }
}

// MARK: - Earning
struct Earning: Codable {
    let seasonYear: Int
    let earnings: Double
    let eventType: String

    enum CodingKeys: String, CodingKey {
        case seasonYear = "SeasonYear"
        case earnings = "Earnings"
        case eventType = "EventType"
    }
}

// MARK: - Ranking
struct Ranking: Codable {
    let rank, rankType, eventName: String
    let season: Int
    let tourId: Int?
    let circuitId: Int?

    enum CodingKeys: String, CodingKey {
        case rank = "Rank"
        case rankType = "RankType"
        case eventName = "EventName"
        case season = "Season"
        case tourId = "TourId"
        case circuitId = "CircuitId"
    }
}

// MARK: - Result
struct BioResult: Codable {
    let rodeoId: Int
    let rodeoName, city, state, startDate: String
    let endDate: String
    let rodeoResultId: Int
    let eventType: String
    let place: Int
    let payoff,time, score: Double
    let round: String
    let stockId: Int
//    let stock: JSONNull?
    let seasonYear: Int

    enum CodingKeys: String, CodingKey {
        case rodeoId = "RodeoId"
        case rodeoName = "RodeoName"
        case city = "City"
        case state = "StateAbbrv"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case rodeoResultId = "RodeoResultId"
        case eventType = "EventType"
        case score = "Score"
        case place = "Place"
        case payoff = "Payoff"
        case time = "Time"
        case round = "Round"
        case stockId = "StockId"
//        case stock = "Stock"
        case seasonYear = "SeasonYear"
    }
}

struct BioAverage: Codable {
    let rodeoId: Int
    let rodeoName, city, state, startDate: String
    let endDate: String
    let aggregateId: Int
    let eventType: String
    let place: Int
    let payoff,time, score: Double
    let round: String
//    let stock: JSONNull?
    let seasonYear: Int

    enum CodingKeys: String, CodingKey {
        case rodeoId = "RodeoId"
        case rodeoName = "RodeoName"
        case city = "City"
        case state = "StateAbbrv"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case aggregateId = "AggregateId"
        case eventType = "EventType"
        case score = "Score"
        case place = "Place"
        case payoff = "Payoff"
        case time = "Time"
        case round = "Round"
//        case stock = "Stock"
        case seasonYear = "SeasonYear"
    }
}

struct CareerWithEarinings {
    let season: String
    let rank: String
    let standingType: String
    let earnings: String
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func cowboyTask(with url: URL, completionHandler: @escaping (Bio?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}


