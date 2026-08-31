import SwiftUI

struct ScheduleDaysheet: Identifiable {
    let id = UUID()
    let startDateKey: String
    let rounds: [ScheduleDaysheetRound]

    init(startDateKey: String, performances: [String: [String: DaysheetEventGroup]]) {
        self.startDateKey = startDateKey
        self.rounds = performances.map { name, eventsByName in
            ScheduleDaysheetRound(
                displayName: Self.roundDisplayName(from: name),
                eventsByName: eventsByName
            )
        }
        .sorted { lhs, rhs in
            if lhs.roundNumber == rhs.roundNumber {
                return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
            }
            return lhs.roundNumber < rhs.roundNumber
        }
    }

    private var parsedStartDate: Date? {
        startDateKey.rodeoDate
    }

    var sortDate: Date {
        parsedStartDate ?? .distantFuture
    }

    static func extractRoundNumber(from value: String) -> Int {
        let pattern = #"(?i)(?:go|round)\s*(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return 0 }
        let nsText = value as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        guard
            let match = regex.firstMatch(in: value, range: fullRange),
            match.numberOfRanges > 1
        else {
            return 0
        }

        let goRange = match.range(at: 1)
        guard goRange.location != NSNotFound else { return 0 }
        return nsText.substring(with: goRange).int
    }

    static func roundDisplayName(from value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Round" }
        return trimmed.replacingOccurrences(
            of: #"(?i)\bgo\b"#,
            with: "Round",
            options: .regularExpression
        )
    }

    var startDisplay: String {
        guard let date = parsedStartDate else { return startDateKey }
        return RodeoDateParser.string(from: date, format: "EEE, MMM d • h:mm a")
    }

    var eventNames: [String] {
        Array(Set(rounds.flatMap { $0.eventsByName.keys })).sorted()
    }

    var roundsDisplay: String {
        rounds.map(\.displayName).joined(separator: " • ")
    }
}

struct ScheduleDaysheetRound: Identifiable {
    let id = UUID()
    let displayName: String
    let eventsByName: [String: DaysheetEventGroup]

    var roundNumber: Int {
        ScheduleDaysheet.extractRoundNumber(from: displayName)
    }
}

struct DaysheetDetailView: View {
    let rodeoName: String
    let daysheet: ScheduleDaysheet
    let preferredEvent: Events.CodingKeys?
    @State private var selectedEventName: String = ""

    init(
        rodeoName: String,
        daysheet: ScheduleDaysheet,
        preferredEvent: Events.CodingKeys? = nil
    ) {
        self.rodeoName = rodeoName
        self.daysheet = daysheet
        self.preferredEvent = preferredEvent
    }
    
    private var daysheetTitle: String {
        if !daysheet.roundsDisplay.isEmpty {
            return daysheet.roundsDisplay
        }
        return "Daysheet"
    }

    private struct DaysheetDisplayRow: Identifiable {
        let id = UUID()
        let entry: DaysheetEntry
        let drawOrder: Int?
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppSpace.xxs) {
                    Text(daysheetTitle)
                        .font(.appBodyStrong)
                    Text(daysheet.startDisplay)
                        .font(.appCaptionStrong)
                        .foregroundColor(.appTertiary)
                }
            }

            if !daysheet.eventNames.isEmpty {
                Section("Event") {
                    daysheetEventDropdown
                }
            }

            let selectedRounds = daysheet.rounds.compactMap { round -> (String, DaysheetEventGroup)? in
                guard let group = round.eventsByName[selectedEventName] else { return nil }
                return (round.displayName, group)
            }

            if selectedRounds.isEmpty {
                Section(selectedEventName) {
                    VStack(alignment: .leading, spacing: AppSpace.sm) {
                        Text(String(format: NSLocalizedString("No day sheets for %@", comment: ""), selectedEventName))
                            .font(.appCaption)
                            .foregroundColor(.appTertiary)

                        Menu {
                            ForEach(daysheet.eventNames, id: \.self) { eventName in
                                Button(eventName) {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                        selectedEventName = eventName
                                    }
                                }
                            }
                        } label: {
                            Label("Change Event", systemImage: "slider.horizontal.3")
                        }
                        .buttonStyle(.loadingButton(false))
                    }
                    .padding(.vertical, AppSpace.xs)
                }
            } else {
                ForEach(Array(selectedRounds.enumerated()), id: \.offset) { _, item in
                    let roundLabel = item.0
                    let eventRows = makeDisplayRows(from: item.1.events)
                    let rerideRows = item.1.rerides.sorted { lhs, rhs in
                        let left = lhs.rerideNumber ?? Int.max
                        let right = rhs.rerideNumber ?? Int.max
                        if left == right {
                            return (lhs.stockName ?? "").localizedCaseInsensitiveCompare(rhs.stockName ?? "") == .orderedAscending
                        }
                        return left < right
                    }

                    Section(roundLabel) {
                        if eventRows.isEmpty {
                            Text("No entries")
                                .font(.appCaption)
                                .foregroundColor(.appTertiary)
                        } else {
                            ForEach(eventRows) { row in
                                daysheetEntryRow(row: row)
                            }
                        }
                    }

                    if !rerideRows.isEmpty {
                        Section("\(roundLabel) Rerides") {
                            ForEach(rerideRows) { reride in
                                rerideEntryRow(reride)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(rodeoName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedEventName.isEmpty {
                selectedEventName = initialEventName()
            }
            AnalyticsService.shared.track(
                .daysheetViewed(
                    event: selectedEventName.isEmpty ? "unknown" : selectedEventName,
                    rounds: daysheet.rounds.count
                )
            )
        }
        .onChange(of: daysheet.eventNames) { _, newValue in
            if !newValue.contains(selectedEventName) {
                selectedEventName = initialEventName()
            }
        }
    }

    private var daysheetEventDropdown: some View {
        Menu {
            ForEach(daysheet.eventNames, id: \.self) { eventName in
                Button(eventName) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selectedEventName = eventName
                    }
                }
            }
        } label: {
            HStack(spacing: AppSpace.xs) {
                Text(selectedEventName.isEmpty ? "Event" : selectedEventName)
                    .font(.appCaptionStrong)
                    .foregroundColor(.appPrimary)
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.appSecondary)
            }
            .padding(.vertical, AppSpace.sm)
            .padding(.horizontal, AppSpace.lg)
            .background {
                Capsule(style: .continuous)
                    .fill(Color.appBg)
            }
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.18), lineWidth: AppStroke.hairline)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select Daysheet Event")
    }

    private func initialEventName() -> String {
        if let preferredEventName = matchingEventName(for: preferredEvent) {
            return preferredEventName
        }

        return daysheet.eventNames.first ?? ""
    }

    private func matchingEventName(for event: Events.CodingKeys?) -> String? {
        guard let event else { return nil }

        let preferredNames = [
            event.title,
            event.rawValue,
            event.title.replacingOccurrences(of: "-", with: " ")
        ]
        .map(normalizedEventName)

        return daysheet.eventNames.first { eventName in
            preferredNames.contains(normalizedEventName(eventName))
        }
    }

    private func normalizedEventName(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "Roping", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func makeDisplayRows(from entries: [DaysheetEntry]) -> [DaysheetDisplayRow] {
        let sortedEntries = entries.sorted { lhs, rhs in
            let left = lhs.goPosition ?? Int.max
            let right = rhs.goPosition ?? Int.max
            if left == right {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return left < right
        }

        var rows = [DaysheetDisplayRow]()
        var currentDrawOrder = 1

        for entry in sortedEntries {
            if entry.hasTurnout {
                rows.append(DaysheetDisplayRow(entry: entry, drawOrder: nil))
            } else {
                rows.append(DaysheetDisplayRow(entry: entry, drawOrder: currentDrawOrder))
                currentDrawOrder += 1
            }
        }

        return rows
    }

    private func daysheetEntryRow(row: DaysheetDisplayRow) -> some View {
        let entry = row.entry

        return HStack(alignment: .center, spacing: AppSpace.md) {
            if let drawOrder = row.drawOrder {
                Text("\(drawOrder)")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.appSecondary)
                    .frame(width: 28, alignment: .center)
            } else {
                Color.clear
                    .frame(width: 28, height: 1)
            }

            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpace.xs) {
                    Text(entry.name)
                        .font(.appBodyStrong)
                        .foregroundColor(row.drawOrder == nil ? .appTertiary : .appPrimary)
                        .strikethrough(row.drawOrder == nil, color: .appTertiary)

                    if let contestantNumber = entry.contestantNumber, row.drawOrder != nil {
                        Text("No. \(contestantNumber)")
                            .font(.appCaption)
                            .foregroundColor(.appTertiary)
                    }
                }

                if let hometown = entry.hometown, !hometown.isEmpty {
                    Text(hometown)
                        .font(.appCaption)
                        .foregroundColor(.appTertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, AppSpace.xxs)
    }

    private func rerideEntryRow(_ reride: DaysheetRerideEntry) -> some View {
        HStack(alignment: .center, spacing: AppSpace.md) {
            if let rerideNumber = reride.rerideNumber {
                Text("\(rerideNumber)")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.appSecondary)
                    .frame(width: 28, alignment: .center)
            } else {
                Color.clear
                    .frame(width: 28, height: 1)
            }

            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(reride.stockName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "Reride Stock")
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)

                HStack(spacing: AppSpace.xs) {
                    if let brand = reride.brand?.trimmingCharacters(in: .whitespacesAndNewlines), !brand.isEmpty {
                        Text("Brand \(brand)")
                    }

                    if let contractor = reride.contractorInitials?.trimmingCharacters(in: .whitespacesAndNewlines), !contractor.isEmpty {
                        Text(contractor)
                    }
                }
                .font(.appCaption)
                .foregroundColor(.appTertiary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpace.xxs)
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
