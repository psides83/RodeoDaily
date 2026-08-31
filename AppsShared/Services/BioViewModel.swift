//
//  AthleteAPI.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation
import SwiftData
import SwiftUI
import UserNotifications

@MainActor
class BioViewModel: ObservableObject {
    private let apiUrls = ApiUrls()
//    @ObservedObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.5)
    
    static var defaultSeason: String {
        let now = Date()
        let seasonYear = now.monthInt >= 10 ? now.yearInt + 1 : now.yearInt
        return seasonYear.string
    }
    
    @Published var bio: BioData = BioData()
    @Published var selectedEvent: String?
    @Published var selectedSeason = BioViewModel.defaultSeason
    @Published var sortResultsBy: BioResult.SortingKeyPath = .rodeoDate
    @Published var infoType: BioInfoType = .stats
    @Published var showSearchBar = false
    @Published var loading = false
    @Published private(set) var bioLoadError: String?
    @Published var searchText = ""
    @Published var bioScrollOffset: CGFloat = 0
    @Published var bioPullDownOffset: CGFloat = 0
    @Published var bioHasUserScrolled = false
    
//    let months = DateFormatter().shortMonthSymbols
    
    enum BioInfoType: String, CaseIterable {
        case stats = "Stats"
        case results = "Results"
        case career = "Career"
        case highlights = "Highlights"
    }
    
    enum Months: String, CaseIterable {
        case jan = "Jan"
        case feb = "Feb"
        case mar = "Mar"
        case apr = "Apr"
        case may = "May"
        case jun = "Jun"
        case jul = "Jul"
        case aug = "Aug"
        case sep = "Sep"
        case oct = "Oct"
        case nov = "Nov"
        case dec = "Dec"
    }
    
    struct FollowSnapshot {
        let athleteId: Int
        let athleteName: String
        let event: String
        let rank: String
        let earnings: Double
        let latestResultId: Int
    }
    
    private enum FollowAlertDefaults {
        static let pushEnabled = "follow_alert_push_enabled"
        static let rankEnabled = "follow_alert_rank_enabled"
        static let resultEnabled = "follow_alert_result_enabled"
        static let quietHoursEnabled = "follow_alert_quiet_hours_enabled"
        static let quietStartHour = "follow_alert_quiet_start_hour"
        static let quietEndHour = "follow_alert_quiet_end_hour"
        static let dailyCapEnabled = "follow_alert_daily_cap_enabled"
        static let dailyCapCount = "follow_alert_daily_cap_count"
        static let digestEnabled = "follow_alert_digest_enabled"
        static let muteUntilKeyPrefix = "follow_alert_muted_until_"
        static let deliveredDayKeyPrefix = "follow_alert_delivered_day_"
        static let pendingDigestDayKeyPrefix = "follow_alert_pending_digest_day_"
        static let lastSentAtKeyPrefix = "follow_alert_last_sent_"
        static let lastPayloadKeyPrefix = "follow_alert_last_payload_"
        static let lastNotifiedRankKeyPrefix = "follow_alert_last_notified_rank_"
    }
    
    private enum FollowAlertNotification {
        static let categoryId = "FOLLOW_ALERT_CATEGORY"
        static let digestIdentifierPrefix = "follow-alert-digest-"
        static let athleteIdKey = "athlete_id"
        static let eventKey = "event"
        static let alertTypeKey = "alert_type"
    }
    
    private let followAlertCooldownSeconds: TimeInterval = 60 * 60 * 12
    private let duplicateDebounceSeconds: TimeInterval = 60 * 10
    
    // MARK: - Methods
    func setSelectedEvent(_ event: String) async {
        self.selectedEvent = event
    }
    
    func getBio(for athleteId: Int) async {
        setLoading()
        bioLoadError = nil
        
        let url = apiUrls.bioUrl(for: athleteId)
        print("bioUrl: ", url)
        
        do {
            self.bio = try await APIClient.fetch(Bio.self, from: url).data
            print(self.bio.events)

            if selectedEvent == nil {
                self.selectedEvent = bio.topEvent.withTeamRopingConversion
            }
//            print(self.bio.contestantId)
            self.endLoading()
        } catch {
            bioLoadError = bioLoadFailureDiagnostic(for: error)
            self.endLoading()
            print("Error decoding: ", error)
        }
    }

    private func bioLoadFailureDiagnostic(for error: Error) -> String {
        switch error {
        case DecodingError.keyNotFound(let key, let context):
            return "Response is missing '\(key.stringValue)' at \(codingPathDescription(context.codingPath))."
        case DecodingError.valueNotFound(let type, let context):
            return "Response contains no \(type) value at \(codingPathDescription(context.codingPath))."
        case DecodingError.typeMismatch(let type, let context):
            return "Response has an invalid \(type) value at \(codingPathDescription(context.codingPath))."
        case DecodingError.dataCorrupted(let context):
            return "Response data is invalid at \(codingPathDescription(context.codingPath)): \(context.debugDescription)"
        default:
            return error.localizedDescription
        }
    }

    private func codingPathDescription(_ codingPath: [CodingKey]) -> String {
        let path = codingPath.map(\.stringValue).joined(separator: ".")
        return path.isEmpty ? "the athlete profile" : path
    }
    
    func setLoading() {
        DispatchQueue.main.async {
            self.loading = true
        }
    }
    
    func endLoading() {
        DispatchQueue.main.async {
            self.loading = false
            print("loading ended")
        }
    }
    
    func seasonRanking() -> String {
        guard let event = selectedEvent else { return "No event selected" }
        let ranking = bio.currentSeasonRankings().first(where: { $0.event == event })
        
        if let rank = ranking {
            let eventName = rank.eventName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return "\(rank.ranking) in \(eventName) with \(rank.earnings.currencyABS)"
        }
        
        return "Unranked in \(event.eventDisplay)"
    }
    
    func followSnapshot(fallbackAthleteId: Int? = nil) -> FollowSnapshot? {
        let athleteId = bio.contestantId != 0 ? bio.contestantId : (fallbackAthleteId ?? 0)
        guard athleteId != 0 else { return nil }
        
        let selected = selectedEvent?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let event = selected.isEmpty ? bio.topEvent.withTeamRopingConversion : selected
        return followSnapshot(for: event, athleteId: athleteId)
    }
    
    private func followSnapshot(for event: String, athleteId: Int? = nil) -> FollowSnapshot {
        let resolvedAthleteId = athleteId ?? bio.contestantId
        let seasonRanking = bio.currentSeasonRankings().first { $0.event == event }
        let rank = seasonRanking?.ranking ?? "Unranked"
        let earnings = seasonRanking?.earnings ?? 0
        
        let latestResultId = bio.resultsAndAveragesCombined()
            .filter { $0.eventType == event }
            .sorted {
                if $0.endDate == $1.endDate {
                    return $0.rodeoResultId > $1.rodeoResultId
                }
                return $0.endDate > $1.endDate
            }
            .first?
            .rodeoResultId ?? 0
        
        return FollowSnapshot(
            athleteId: resolvedAthleteId,
            athleteName: bio.name,
            event: event,
            rank: rank,
            earnings: earnings,
            latestResultId: latestResultId
        )
    }
    
    @MainActor
    func evaluateFollowAlerts(modelContext: ModelContext) -> [FollowAlertEvent] {
        let athleteId = bio.contestantId
        guard athleteId != 0 else { return [] }
        
        let descriptor = FetchDescriptor<FollowedAthlete>(
            predicate: #Predicate { $0.athleteId == athleteId }
        )
        
        let followedAthletes = (try? modelContext.fetch(descriptor)) ?? []
        guard !followedAthletes.isEmpty else { return [] }
        
        var createdAlerts = [FollowAlertEvent]()
        let defaults = UserDefaults.standard
        let rankEnabled = defaults.object(forKey: FollowAlertDefaults.rankEnabled) == nil
            ? true
            : defaults.bool(forKey: FollowAlertDefaults.rankEnabled)
        let resultEnabled = defaults.object(forKey: FollowAlertDefaults.resultEnabled) == nil
            ? true
            : defaults.bool(forKey: FollowAlertDefaults.resultEnabled)
        
        followedAthletes.forEach { followed in
            let snapshot = followSnapshot(for: followed.event, athleteId: athleteId)
            let previousRank = normalizedRank(followed.lastKnownRank)
            let currentRank = normalizedRank(snapshot.rank)
            
            if !isFollowAlertMuted(athleteId: snapshot.athleteId) {
                if rankEnabled &&
                    shouldCreateRankAlert(
                        athleteId: snapshot.athleteId,
                        event: snapshot.event,
                        previousRank: previousRank,
                        currentRank: currentRank,
                        modelContext: modelContext
                    ) {
                    let alert = FollowAlertEvent(
                        athleteId: snapshot.athleteId,
                        athleteName: snapshot.athleteName,
                        event: snapshot.event,
                        alertType: "rank_change",
                        title: "Rank changed",
                        message: "\(snapshot.athleteName) moved from \(previousRank) to \(currentRank) in \(snapshot.event.eventDisplay)."
                    )
                    modelContext.insert(alert)
                    createdAlerts.append(alert)
                    setLastNotifiedRank(currentRank, athleteId: snapshot.athleteId, event: snapshot.event)
                } else if currentRank != "Unranked" {
                    // Establish/refresh baseline to prevent repeated initial "Unranked -> X" alerts.
                    setLastNotifiedRank(currentRank, athleteId: snapshot.athleteId, event: snapshot.event)
                }
                
                if resultEnabled &&
                    followed.lastKnownResultId > 0 &&
                    snapshot.latestResultId > followed.lastKnownResultId &&
                    canCreateFollowAlert(
                        athleteId: snapshot.athleteId,
                        event: snapshot.event,
                        alertType: "new_result",
                        modelContext: modelContext
                    ) {
                    let alert = FollowAlertEvent(
                        athleteId: snapshot.athleteId,
                        athleteName: snapshot.athleteName,
                        event: snapshot.event,
                        alertType: "new_result",
                        title: "New result posted",
                        message: "\(snapshot.athleteName) has a new \(snapshot.event.eventDisplay) result."
                    )
                    modelContext.insert(alert)
                    createdAlerts.append(alert)
                }
            }
            
            followed.event = snapshot.event
            followed.name = snapshot.athleteName
            followed.lastKnownRank = snapshot.rank
            followed.lastKnownResultId = snapshot.latestResultId
            followed.lastKnownEarnings = snapshot.earnings
            followed.updatedAt = .now
        }
        
        try? modelContext.save()
        scheduleLocalNotifications(for: createdAlerts)
        return createdAlerts
    }

    @MainActor
    private func shouldCreateRankAlert(
        athleteId: Int,
        event: String,
        previousRank: String,
        currentRank: String,
        modelContext: ModelContext
    ) -> Bool {
        guard previousRank != currentRank else { return false }
        guard !previousRank.isEmpty, !currentRank.isEmpty else { return false }
        guard previousRank != "Unranked", currentRank != "Unranked" else { return false }

        let lastNotifiedRank = lastNotifiedRank(athleteId: athleteId, event: event)
        guard lastNotifiedRank != currentRank else { return false }

        return canCreateFollowAlert(
            athleteId: athleteId,
            event: event,
            alertType: "rank_change",
            modelContext: modelContext
        )
    }
    
    @MainActor
    private func canCreateFollowAlert(
        athleteId: Int,
        event: String,
        alertType: String,
        modelContext: ModelContext
    ) -> Bool {
        let cutoff = Date().addingTimeInterval(-followAlertCooldownSeconds)
        
        let recentDescriptor = FetchDescriptor<FollowAlertEvent>(
            predicate: #Predicate {
                $0.athleteId == athleteId
                &&
                $0.event == event
                &&
                $0.alertType == alertType
                &&
                $0.createdAt >= cutoff
            }
        )
        
        let recentAlerts = (try? modelContext.fetch(recentDescriptor)) ?? []
        
        return recentAlerts.isEmpty
    }
    
    private func scheduleLocalNotifications(for alerts: [FollowAlertEvent]) {
        guard !alerts.isEmpty else { return }
        
        let defaults = UserDefaults.standard
        let pushEnabled = defaults.object(forKey: FollowAlertDefaults.pushEnabled) == nil
            ? true
            : defaults.bool(forKey: FollowAlertDefaults.pushEnabled)
        guard pushEnabled else { return }
        
        let quietHoursEnabled = defaults.object(forKey: FollowAlertDefaults.quietHoursEnabled) == nil
            ? true
            : defaults.bool(forKey: FollowAlertDefaults.quietHoursEnabled)
        let quietStartHour = defaults.object(forKey: FollowAlertDefaults.quietStartHour) == nil
            ? 22
            : defaults.integer(forKey: FollowAlertDefaults.quietStartHour)
        let quietEndHour = defaults.object(forKey: FollowAlertDefaults.quietEndHour) == nil
            ? 7
            : defaults.integer(forKey: FollowAlertDefaults.quietEndHour)
        
        let dailyCapEnabled = defaults.object(forKey: FollowAlertDefaults.dailyCapEnabled) == nil
            ? true
            : defaults.bool(forKey: FollowAlertDefaults.dailyCapEnabled)
        let dailyCapCount = defaults.object(forKey: FollowAlertDefaults.dailyCapCount) == nil
            ? 6
            : max(1, defaults.integer(forKey: FollowAlertDefaults.dailyCapCount))
        let digestEnabled = defaults.object(forKey: FollowAlertDefaults.digestEnabled) == nil
            ? true
            : defaults.bool(forKey: FollowAlertDefaults.digestEnabled)
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                return
            }
            
            let now = Date()
            let dayKey = self.dayKey(for: now)
            let inQuietHours = quietHoursEnabled
                ? self.isInQuietHours(date: now, startHour: quietStartHour, endHour: quietEndHour)
                : false
            
            alerts.forEach { alert in
                if self.shouldDebounceNotification(alert: alert, now: now) {
                    return
                }
                
                let deliveredToday = self.deliveredCount(for: dayKey)
                let hitDailyCap = dailyCapEnabled && deliveredToday >= dailyCapCount
                
                if inQuietHours || hitDailyCap {
                    guard digestEnabled else { return }
                    
                    self.incrementPendingDigestCount(for: dayKey)
                    self.scheduleDigestNotification(
                        center: center,
                        dayKey: dayKey,
                        referenceDate: now,
                        quietHoursEnabled: quietHoursEnabled,
                        quietStartHour: quietStartHour,
                        quietEndHour: quietEndHour
                    )
                    return
                }
                
                let content = UNMutableNotificationContent()
                content.title = alert.title
                content.body = alert.message
                content.sound = .default
                content.categoryIdentifier = FollowAlertNotification.categoryId
                content.userInfo = [
                    FollowAlertNotification.athleteIdKey: alert.athleteId,
                    FollowAlertNotification.eventKey: alert.event,
                    FollowAlertNotification.alertTypeKey: alert.alertType
                ]
                
                let request = UNNotificationRequest(
                    identifier: "follow-alert-\(alert.id.uuidString)",
                    content: content,
                    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                )
                
                center.add(request)
                self.incrementDeliveredCount(for: dayKey)
            }
        }
    }
    
    private func shouldDebounceNotification(alert: FollowAlertEvent, now: Date) -> Bool {
        let defaults = UserDefaults.standard
        let stateKey = "\(alert.athleteId)_\(alert.alertType)_\(alert.event)"
        let sentAtKey = "\(FollowAlertDefaults.lastSentAtKeyPrefix)\(stateKey)"
        let payloadKey = "\(FollowAlertDefaults.lastPayloadKeyPrefix)\(stateKey)"
        let lastSentAt = defaults.double(forKey: sentAtKey)
        let lastPayload = defaults.string(forKey: payloadKey) ?? ""
        let currentPayload = "\(alert.title)|\(alert.message)"
        
        // If the exact same rank alert keeps getting recreated, suppress it for the
        // full follow cooldown window instead of only 10 minutes.
        let debounceWindow: TimeInterval
        if alert.alertType == "rank_change", lastPayload == currentPayload {
            debounceWindow = followAlertCooldownSeconds
        } else {
            debounceWindow = duplicateDebounceSeconds
        }
        
        if lastSentAt > 0 && now.timeIntervalSince1970 - lastSentAt < debounceWindow {
            return true
        }
        
        defaults.set(now.timeIntervalSince1970, forKey: sentAtKey)
        defaults.set(currentPayload, forKey: payloadKey)
        return false
    }

    private func normalizedRank(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Unranked" }
        return trimmed
    }

    private func rankStateKey(athleteId: Int, event: String) -> String {
        "\(athleteId)_\(event)"
    }

    private func lastNotifiedRank(athleteId: Int, event: String) -> String {
        let key = "\(FollowAlertDefaults.lastNotifiedRankKeyPrefix)\(rankStateKey(athleteId: athleteId, event: event))"
        return UserDefaults.standard.string(forKey: key) ?? ""
    }

    private func setLastNotifiedRank(_ rank: String, athleteId: Int, event: String) {
        let key = "\(FollowAlertDefaults.lastNotifiedRankKeyPrefix)\(rankStateKey(athleteId: athleteId, event: event))"
        UserDefaults.standard.set(rank, forKey: key)
    }
    
    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func deliveredCount(for dayKey: String) -> Int {
        let key = "\(FollowAlertDefaults.deliveredDayKeyPrefix)\(dayKey)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    private func incrementDeliveredCount(for dayKey: String) {
        let key = "\(FollowAlertDefaults.deliveredDayKeyPrefix)\(dayKey)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }
    
    private func pendingDigestCount(for dayKey: String) -> Int {
        let key = "\(FollowAlertDefaults.pendingDigestDayKeyPrefix)\(dayKey)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    private func incrementPendingDigestCount(for dayKey: String) {
        let key = "\(FollowAlertDefaults.pendingDigestDayKeyPrefix)\(dayKey)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }
    
    private func isInQuietHours(date: Date, startHour: Int, endHour: Int) -> Bool {
        guard startHour != endHour else { return false }
        
        let hour = Calendar.current.component(.hour, from: date)
        
        if startHour < endHour {
            return hour >= startHour && hour < endHour
        }
        
        return hour >= startHour || hour < endHour
    }
    
    private func scheduleDigestNotification(
        center: UNUserNotificationCenter,
        dayKey: String,
        referenceDate: Date,
        quietHoursEnabled: Bool,
        quietStartHour: Int,
        quietEndHour: Int
    ) {
        let pendingCount = pendingDigestCount(for: dayKey)
        guard pendingCount > 0 else { return }
        
        let fireDate: Date
        if quietHoursEnabled {
            fireDate = nextQuietHoursEnd(
                after: referenceDate,
                quietStartHour: quietStartHour,
                quietEndHour: quietEndHour
            )
        } else {
            fireDate = referenceDate.addingTimeInterval(60 * 10)
        }
        
        let interval = max(5, fireDate.timeIntervalSinceNow)
        
        let content = UNMutableNotificationContent()
        content.title = "Follow Alerts Digest"
        content.body = "You have \(pendingCount) new follow alerts."
        content.sound = .default
        content.userInfo = [FollowAlertNotification.alertTypeKey: "digest"]
        
        let request = UNNotificationRequest(
            identifier: "\(FollowAlertNotification.digestIdentifierPrefix)\(dayKey)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        )
        
        center.add(request)
    }
    
    private func nextQuietHoursEnd(after date: Date, quietStartHour: Int, quietEndHour: Int) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if quietStartHour == quietEndHour {
            return date.addingTimeInterval(60 * 10)
        }
        
        let hour = calendar.component(.hour, from: date)
        
        if quietStartHour < quietEndHour {
            // Quiet window does not wrap midnight (e.g., 01:00 - 06:00).
            return calendar.date(byAdding: .hour, value: quietEndHour, to: startOfDay) ?? date.addingTimeInterval(60 * 10)
        }
        
        // Quiet window wraps midnight (e.g., 22:00 - 07:00).
        if hour >= quietStartHour {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            return calendar.date(byAdding: .hour, value: quietEndHour, to: tomorrow) ?? date.addingTimeInterval(60 * 10)
        }
        
        return calendar.date(byAdding: .hour, value: quietEndHour, to: startOfDay) ?? date.addingTimeInterval(60 * 10)
    }
    
    private func isFollowAlertMuted(athleteId: Int) -> Bool {
        let key = "\(FollowAlertDefaults.muteUntilKeyPrefix)\(athleteId)"
        let mutedUntil = UserDefaults.standard.double(forKey: key)
        guard mutedUntil > 0 else { return false }
        return Date().timeIntervalSince1970 < mutedUntil
    }
    
    // MARK: - Computed Properties
    var results: [BioResult] {
        if let event = selectedEvent {
            return bio.results(
                filteredBy: selectedSeason.int,
                filteredBy: event,
                searchText: searchText,
                sortedBy: sortResultsBy
            )
        }
        
        return []
    }
    
    var scoreTypeText: (scoreType: String, action: String) {
        if selectedEvent == "BR" || selectedEvent == "BB" || selectedEvent == "SB" {
            return (scoreType: "Highest Score:", action: "Ride")
        } else {
            
            return (scoreType: "Fastest Time:", action: "Run")
        }
    }
    
    var currentYearEarnings: String {
        guard let event = selectedEvent else { return "No Event Selected" }
        
        return bio
            .career
            .filter({
                $0.season == Date().yearInt
                &&
                $0.eventType == event
                
            })[0]
            .earnings
            .currencyABS
    }
    
    var careerSeasons: [CareerWithEarinings] {
        bio.careerSeasons(filteredBy: selectedEvent)
    }
}

extension Date {
    var monthAbreviated: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
}
