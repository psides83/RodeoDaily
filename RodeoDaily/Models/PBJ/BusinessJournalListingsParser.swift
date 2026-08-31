import Foundation

enum BusinessJournalListingsParser {
    static func parse(response: BusinessJournalFeedResponse) -> [BusinessJournalFeedItem] {
        var seenIds = Set<String>()
        var parsed = [BusinessJournalFeedItem]()

        for (index, listing) in response.listings.enumerated() {
            guard let item = makeItem(from: listing, fallbackIndex: index, sourceURL: response.source) else { continue }
            guard !seenIds.contains(item.id) else { continue }
            seenIds.insert(item.id)
            parsed.append(item)
        }

        return parsed
    }

    static func parse(jsonObject: Any) -> [BusinessJournalFeedItem] {
        guard
            JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject),
            let response = try? JSONDecoder().decode(BusinessJournalFeedResponse.self, from: data)
        else {
            return []
        }

        return parse(response: response)
    }

    private static func makeItem(from listing: PBJListingDTO, fallbackIndex: Int, sourceURL: String?) -> BusinessJournalFeedItem? {
        let detailFields = buildDetailFields(from: listing)

        let startDate = listing.fields?.eventDateRange?.startDate
        let endDate = listing.fields?.eventDateRange?.endDate
        let singleDate = listing.publishDate
        let dateText = makeDateText(startDate: startDate, endDate: endDate, singleDate: listing.eventDates ?? singleDate)
        let eventStartDate = parseISODate(startDate)
        let eventEndDate = parseISODate(endDate)
        let publishDate = parsePublishDate(listing.publishDate)
        let eventSortDate = eventStartDate
            ?? eventEndDate
            ?? parseEventDateText(listing.eventDates, fallbackDate: publishDate)

        let locationText = listing.location?.trimmed
        let eventsText = formatEvents(listing.fields?.events ?? [])
        let perfsText = formatPerfs(listing.fields?.perfs)
        let specialEntryFeesText = formatEntryFees(listing.fields?.entryFees ?? [])
        let addedMoneyTotal = calculateAddedMoneyTotal(listing.fields?.events ?? [])
        let addedMoneyText = formatMoney(addedMoneyTotal)

        let entryWindowText: String? = {
            let open = formatDateTime(listing.fields?.entriesOpen ?? "") ?? listing.fields?.entriesOpen?.trimmed
            let close = formatDateTime(listing.fields?.entriesClose ?? "") ?? listing.fields?.entriesClose?.trimmed
            if let open, !open.isEmpty, let close, !close.isEmpty {
                return "\(open) - \(close)"
            }
            return open ?? close
        }()

        let subtitle = listing.eventName?.trimmed ?? listing.summaryText?.trimmed
        let source = listing.tour?.trimmed ?? listing.fields?.tour?.trimmed
        let link = sourceURL.flatMap(URL.init(string:))

        let cardTitle = locationText ?? subtitle
        guard let cardTitle, !cardTitle.trimmed.isEmpty else { return nil }

        let id = "rodeo-\(listing.index ?? fallbackIndex)-\(cardTitle)"

        return BusinessJournalFeedItem(
            id: id,
            title: cardTitle,
            subtitle: subtitle,
            dateText: dateText,
            eventSortDate: eventSortDate,
            eventStartDate: eventStartDate,
            eventEndDate: eventEndDate,
            publishDate: publishDate,
            locationText: locationText,
            statusText: nil,
            eventsText: eventsText,
            perfsText: perfsText,
            specialEntryFeesText: specialEntryFeesText,
            addedMoneyText: addedMoneyText,
            addedMoneyTotal: addedMoneyTotal,
            entryWindowText: entryWindowText,
            source: source,
            link: link,
            detailFields: detailFields
        )
    }

    private static func buildDetailFields(from listing: PBJListingDTO) -> [PBJDetailField] {
        var fields = [PBJDetailField]()

        func append(_ key: String, _ label: String, _ value: String?) {
            guard let value = value?.trimmed, !value.isEmpty else { return }
            fields.append(PBJDetailField(id: key, key: key, label: label, value: value))
        }

        append("publish_date", "Publish Date", formatPublishDateText(listing.publishDate))
        append("rodeo_name", "Rodeo Name", listing.eventName)
        append("arena", "Arena", listing.fields?.arena)
        append("address", "Address", listing.fields?.address)

        if let perfs = formatPerfs(listing.fields?.perfs) {
            append("perfs", "Perfs", perfs)
        }
        if let slacks = formatSlacks(listing.fields?.slacks) {
            append("slacks", "Slacks", slacks)
        }
        if let events = formatEvents(listing.fields?.events ?? []) {
            append("events", "Events", events)
        }
        if let fees = formatEntryFees(listing.fields?.entryFees ?? []) {
            append("special_entry_fees", "Special Entry Fees", fees)
        }

        append("permits", "Permits", listing.fields?.permits)
        append("ground_rules", "Ground Rules", listing.fields?.groundRules)
        append("stock_contractor", "Stk Cont.", listing.fields?.stockContractor)
        append("sub_contractors", "Sub Contractors", listing.fields?.subContractors)
        append("eo", "EO", formatDateTime(listing.fields?.entriesOpen ?? "") ?? listing.fields?.entriesOpen)
        append("ec", "EC", formatDateTime(listing.fields?.entriesClose ?? "") ?? listing.fields?.entriesClose)

        return fields
    }

    private static func formatEvents(_ rows: [PBJEventMoneyDTO]) -> String? {
        var grouped = [String: [String]]()
        var sequence = [String]()

        for row in rows {
            guard let event = row.event?.trimmed, !event.isEmpty else { continue }
            let money = formatMoneyToken(row.addedMoney)
            if grouped[money] == nil {
                grouped[money] = []
                sequence.append(money)
            }
            grouped[money]?.append(event)
        }

        let chunks = sequence.compactMap { money -> String? in
            guard let events = grouped[money], !events.isEmpty else { return nil }
            let eventPart = events.joined(separator: " ")
            return money.isEmpty ? eventPart : "\(eventPart) @ \(money)"
        }

        return chunks.isEmpty ? nil : chunks.joined(separator: " ")
    }

    private static func formatEntryFees(_ rows: [PBJEntryFeeDTO]) -> String? {
        let chunks = rows.compactMap { row -> String? in
            guard let event = row.event?.trimmed, !event.isEmpty else { return nil }
            guard let fee = row.fees?.trimmed, !fee.isEmpty else { return nil }
            return "\(event)-\(fee)"
        }
        return chunks.isEmpty ? nil : chunks.joined(separator: "; ")
    }

    private static func formatPerfs(_ perfs: PBJPerfsDTO?) -> String? {
        guard let perfs else { return nil }
        let dates = perfs.perfDates.compactMap { raw in formatDateTime(raw) ?? raw.trimmed }
        guard !dates.isEmpty else { return nil }
        let count = perfs.perfsCount ?? dates.count
        return "\(count) Perfs: " + dates.joined(separator: "; ")
    }

    private static func formatSlacks(_ slacks: PBJSlacksDTO?) -> String? {
        guard let slacks else { return nil }
        let dates = slacks.isoDateTimes.compactMap { raw in formatDateTime(raw) ?? raw.trimmed }
        if !dates.isEmpty { return dates.joined(separator: "; ") }
        return slacks.raw?.trimmed
    }

    private static func calculateAddedMoneyTotal(_ events: [PBJEventMoneyDTO]) -> Double? {
        let values = events.compactMap(\.addedMoney)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +)
    }

    private static func formatMoney(_ value: Double?) -> String? {
        guard let value else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value))
    }

    private static func formatMoneyToken(_ value: Double?) -> String {
        guard let value else { return "" }
        return "$\(Int(value))"
    }

    private static func makeDateText(startDate: String?, endDate: String?, singleDate: String?) -> String? {
        let start = formatDateNoYear(startDate)
        let end = formatDateNoYear(endDate)
        let single = formatDateNoYear(singleDate)

        if let start, !start.isEmpty, let end, !end.isEmpty {
            return "\(start)-\(end)"
        }
        return start ?? end ?? single
    }

    private static func parseISODate(_ value: String?) -> Date? {
        guard let value = value?.trimmed, !value.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    private static func parsePublishDate(_ value: String?) -> Date? {
        guard let value = value?.trimmed, !value.isEmpty else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        let formats = ["yyyy MMMM dd", "yyyy MMM dd", "yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss"]
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return nil
    }

    private static func formatPublishDateText(_ value: String?) -> String? {
        guard let date = parsePublishDate(value) else { return formatDateNoYear(value) }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private static func formatDateNoYear(_ value: String?) -> String? {
        guard let value = value?.trimmed, !value.isEmpty else { return nil }

        if let isoDate = parseISODate(value) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "MMM d"
            return formatter.string(from: isoDate)
        }

        if let date = parsePublishDate(value) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }

        let components = value.split(separator: " ")
        if let first = components.first, first.count == 4, Int(first) != nil {
            return components.dropFirst().joined(separator: " ")
        }

        return value
    }

    private static func parseEventDateText(_ value: String?, fallbackDate: Date?) -> Date? {
        guard let value = value?.trimmed, !value.isEmpty else { return nil }

        let pattern = "(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\\s+(\\d{1,2})"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let nsRange = NSRange(value.startIndex..<value.endIndex, in: value)
        guard let match = regex.firstMatch(in: value, options: [], range: nsRange),
              match.numberOfRanges >= 3,
              let monthRange = Range(match.range(at: 1), in: value),
              let dayRange = Range(match.range(at: 2), in: value) else {
            return nil
        }

        let monthToken = String(value[monthRange])
        guard let day = Int(value[dayRange]) else { return nil }

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "en_US_POSIX")
        monthFormatter.dateFormat = "MMM"

        let monthShort = String(monthToken.prefix(3)).capitalized
        guard let monthDate = monthFormatter.date(from: monthShort) else { return nil }
        let month = Calendar.current.component(.month, from: monthDate)

        let year = fallbackDate.map { Calendar.current.component(.year, from: $0) } ?? Calendar.current.component(.year, from: .now)
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    private static func formatDateTime(_ value: String) -> String? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]

        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.timeZone = TimeZone(secondsFromGMT: 0)

        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.timeZone = TimeZone.current
        output.dateFormat = "MMM d- h:mm a"

        for format in formats {
            parser.dateFormat = format
            if let date = parser.date(from: value) {
                if format == "yyyy-MM-dd" {
                    output.dateFormat = "MMM d"
                } else {
                    output.dateFormat = "MMM d- h:mm a"
                }
                return output.string(from: date)
            }
        }

        return nil
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
