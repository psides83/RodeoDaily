import Foundation

struct BusinessJournalFeedResponse: Decodable {
    let scrapedAt: String?
    let source: String?
    let runDate: String?
    let listingCount: Int?
    let addedCount: Int?
    let skippedExistingCount: Int?
    let prunedCount: Int?
    let listings: [PBJListingDTO]
}

struct PBJListingDTO: Decodable {
    let index: Int?
    let summaryText: String?
    let publishDate: String?
    let location: String?
    let eventDates: String?
    let eventName: String?
    let fields: PBJListingFieldsDTO?
    let detailLines: [String]
    let detailText: String?
    let tour: String?

    private enum CodingKeys: String, CodingKey {
        case index
        case summaryText
        case publishDate
        case location
        case eventDates
        case eventName
        case fields
        case detailLines
        case detailText
        case tour
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decodeIfPresent(Int.self, forKey: .index)
        summaryText = try container.decodeIfPresent(String.self, forKey: .summaryText)
        publishDate = try container.decodeIfPresent(String.self, forKey: .publishDate)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        eventDates = try container.decodeIfPresent(String.self, forKey: .eventDates)
        eventName = try container.decodeIfPresent(String.self, forKey: .eventName)
        fields = try container.decodeIfPresent(PBJListingFieldsDTO.self, forKey: .fields)
        detailLines = try container.decodeIfPresent([String].self, forKey: .detailLines) ?? []
        detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        tour = try container.decodeIfPresent(String.self, forKey: .tour)
    }
}

struct PBJListingFieldsDTO: Decodable {
    let arena: String?
    let address: String?
    let eventDateRange: PBJEventDateRangeDTO?
    let perfs: PBJPerfsDTO?
    let slacks: PBJSlacksDTO?
    let events: [PBJEventMoneyDTO]
    let entryFees: [PBJEntryFeeDTO]
    let permits: String?
    let groundRules: String?
    let stockContractor: String?
    let subContractors: String?
    let entriesOpen: String?
    let entriesClose: String?
    let tour: String?

    private enum CodingKeys: String, CodingKey {
        case arena
        case address
        case eventDateRange
        case perfs
        case slacks
        case events
        case entryFees
        case permits
        case groundRules
        case stockContractor
        case subContractors
        case entriesOpen
        case entriesClose
        case tour
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        arena = try container.decodeIfPresent(String.self, forKey: .arena)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        eventDateRange = try container.decodeIfPresent(PBJEventDateRangeDTO.self, forKey: .eventDateRange)
        perfs = try container.decodeIfPresent(PBJPerfsDTO.self, forKey: .perfs)
        slacks = try container.decodeIfPresent(PBJSlacksDTO.self, forKey: .slacks)
        events = try container.decodeIfPresent([PBJEventMoneyDTO].self, forKey: .events) ?? []
        entryFees = try container.decodeIfPresent([PBJEntryFeeDTO].self, forKey: .entryFees) ?? []
        permits = try container.decodeIfPresent(String.self, forKey: .permits)
        groundRules = try container.decodeIfPresent(String.self, forKey: .groundRules)
        stockContractor = try container.decodeIfPresent(String.self, forKey: .stockContractor)
        subContractors = try container.decodeIfPresent(String.self, forKey: .subContractors)
        entriesOpen = try container.decodeIfPresent(String.self, forKey: .entriesOpen)
        entriesClose = try container.decodeIfPresent(String.self, forKey: .entriesClose)
        tour = try container.decodeIfPresent(String.self, forKey: .tour)
    }
}

struct PBJEventDateRangeDTO: Decodable {
    let startDate: String?
    let endDate: String?
}

struct PBJPerfsDTO: Decodable {
    let perfsCount: Int?
    let perfDates: [String]

    private enum CodingKeys: String, CodingKey {
        case perfsCount
        case perfDates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        perfsCount = try container.decodeIfPresent(Int.self, forKey: .perfsCount)
        perfDates = try container.decodeIfPresent([String].self, forKey: .perfDates) ?? []
    }
}

struct PBJSlacksDTO: Decodable {
    let raw: String?
    let isoDateTimes: [String]

    private enum CodingKeys: String, CodingKey {
        case raw
        case isoDateTimes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        raw = try container.decodeIfPresent(String.self, forKey: .raw)
        isoDateTimes = try container.decodeIfPresent([String].self, forKey: .isoDateTimes) ?? []
    }
}

struct PBJEventMoneyDTO: Decodable {
    let event: String?
    let addedMoney: Double?
}

struct PBJEntryFeeDTO: Decodable {
    let event: String?
    let fees: String?
}
