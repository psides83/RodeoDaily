//
//  DaysheetAthleteWidgetApi.swift
//  RodeoDailyWidget
//
//  Created by Codex on 5/16/26.
//

import Foundation

struct DaysheetAthleteWidgetApi {
    private let apiUrls = ApiUrls()
    private let maxSchedulePages = 2
    private let maxRodeosToScan = 16
    private let logPrefix = "[DaysheetAthleteWidgetApi]"

    func loadSchedule(for athlete: WidgetAthleteEntity) async -> [DaysheetAthleteScheduleItem] {
        var upcomingRodeos = [RodeoData]()
        debugLog("load start athleteId=\(athlete.athleteId) athlete='\(athlete.name)' normalized='\(normalized(athlete.name))'")

        for page in 1...maxSchedulePages {
            do {
                let url = apiUrls.rodeoScheduleUrl(with: page, searchText: "", dateParams: "")
                debugLog("schedule page \(page) requesting \(url.absoluteString)")
                let rodeos = try await PaginatedRodeoLoader.fetchPage(from: url)
                let daysheetRodeos = rodeos.filter(isUpcomingDaysheetRodeo)
                debugLog("schedule page \(page) total=\(rodeos.count) daysheetUpcoming=\(daysheetRodeos.count)")
                if !daysheetRodeos.isEmpty {
                    let candidates = daysheetRodeos.map { "\($0.id):\($0.name)" }
                    debugLog("schedule page \(page) candidates=\(candidates)")
                }
                upcomingRodeos.append(contentsOf: daysheetRodeos)
            } catch {
                debugLog("schedule page \(page) failed: \(error.localizedDescription)")
                break
            }
        }

        let uniqueRodeos = PaginatedRodeoLoader.uniqueById(upcomingRodeos)
            .sorted(by: rodeoSort)
            .prefix(maxRodeosToScan)
        debugLog("unique rodeos to scan=\(uniqueRodeos.count)")

        var items = [DaysheetAthleteScheduleItem]()

        for rodeo in uniqueRodeos {
            do {
                let url = apiUrls.rodeoDaysheetsUrl(for: rodeo.id)
                debugLog("daysheet requesting rodeoId=\(rodeo.id) name='\(rodeo.name)' url=\(url.absoluteString)")
                let response = try await APIClient.fetch(DaysheetResponse.self, from: url)
                let scannedCount = entryCount(in: response)
                let matched = matches(in: response, rodeo: rodeo, athlete: athlete)
                debugLog("daysheet rodeoId=\(rodeo.id) performances=\(response.data.count) entries=\(scannedCount) matched=\(matched.count)")
                items.append(contentsOf: matched)
            } catch {
                debugLog("daysheet failed rodeoId=\(rodeo.id): \(error.localizedDescription)")
                continue
            }
        }

        debugLog("load done totalMatches=\(items.count)")
        return items.sorted { $0.startDate < $1.startDate }
    }

    private func isUpcomingDaysheetRodeo(_ rodeo: RodeoData) -> Bool {
        guard rodeo.hasDaysheets else { return false }
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let endDate = rodeo.endDate.rodeoDate ?? rodeo.startDate.rodeoDate ?? .distantPast
        return endDate >= startOfToday
    }

    private func rodeoSort(_ lhs: RodeoData, _ rhs: RodeoData) -> Bool {
        let lhsDate = lhs.startDate.rodeoDate ?? lhs.endDate.rodeoDate ?? .distantFuture
        let rhsDate = rhs.startDate.rodeoDate ?? rhs.endDate.rodeoDate ?? .distantFuture
        return lhsDate < rhsDate
    }

    private func matches(
        in response: DaysheetResponse,
        rodeo: RodeoData,
        athlete: WidgetAthleteEntity
    ) -> [DaysheetAthleteScheduleItem] {
        var items = [DaysheetAthleteScheduleItem]()

        for (startDateKey, performanceGroups) in response.data {
            for (performanceName, roundGroups) in performanceGroups {
                for (_, group) in roundGroups {
                    debugLog("scan rodeoId=\(rodeo.id) start='\(startDateKey)' performance='\(performanceName)' entries=\(group.events.count)")
                    let matchedEntries = group.events.filter { entry in
                        matches(entry: entry, athlete: athlete)
                    }

                    for entry in matchedEntries {
                        let contestantId = entry.contestantId?.string ?? "nil"
                        debugLog("match rodeoId=\(rodeo.id) entryId=\(entry.eventEntryId) contestantId=\(contestantId) name='\(entry.name)' normalized='\(normalized(entry.name))' event='\(entry.eventName)' start='\(entry.startDate)'")
                        let startDate = entry.startDate.rodeoDate
                            ?? startDateKey.rodeoDate
                            ?? rodeo.startDate.rodeoDate
                            ?? Date()
                        let roundLabel = entry.goRound > 0 ? "Round \(entry.goRound)" : performanceName

                        items.append(
                            DaysheetAthleteScheduleItem(
                                id: "\(rodeo.id)-\(entry.eventEntryId)",
                                rodeoName: rodeo.name,
                                location: rodeo.location,
                                eventName: entry.eventName,
                                roundLabel: roundLabel,
                                startDate: startDate,
                                contestantNumber: entry.contestantNumber,
                                isTurnout: entry.hasTurnout
                            )
                        )
                    }
                }
            }
        }

        return items
    }

    private func entryCount(in response: DaysheetResponse) -> Int {
        var total = 0

        for performanceGroups in response.data.values {
            for roundGroups in performanceGroups.values {
                for group in roundGroups.values {
                    total += group.events.count
                }
            }
        }

        return total
    }

    private func matches(entry: DaysheetEntry, athlete: WidgetAthleteEntity) -> Bool {
        if let contestantId = entry.contestantId, contestantId == athlete.athleteId {
            return true
        }

        return normalized(entry.name) == normalized(athlete.name)
    }

    private func normalized(_ value: String) -> String {
        value
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private func debugLog(_ message: String) {
        #if DEBUG
        print("\(logPrefix) \(message)")
        #endif
    }
}
