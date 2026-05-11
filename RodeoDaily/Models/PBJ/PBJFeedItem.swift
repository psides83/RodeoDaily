import Foundation

struct PBJDetailField: Identifiable, Hashable {
    let id: String
    let key: String
    let label: String
    let value: String
}

struct PBJFeedItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let dateText: String?
    let eventSortDate: Date?
    let eventStartDate: Date?
    let eventEndDate: Date?
    let publishDate: Date?
    let locationText: String?
    let statusText: String?
    let eventsText: String?
    let perfsText: String?
    let specialEntryFeesText: String?
    let addedMoneyText: String?
    let addedMoneyTotal: Double?
    let entryWindowText: String?
    let source: String?
    let link: URL?
    let detailFields: [PBJDetailField]
}
