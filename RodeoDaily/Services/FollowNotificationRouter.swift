//
//  FollowNotificationRouter.swift
//  Rodeo Daily
//

import SwiftData
import UIKit
import UserNotifications

final class FollowNotificationRouter: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = FollowNotificationRouter()

    enum Constants {
        static let followAlertCategoryId = "FOLLOW_ALERT_CATEGORY"
        static let viewAthleteActionId = "FOLLOW_ALERT_VIEW_ATHLETE"
        static let mute7DaysActionId = "FOLLOW_ALERT_MUTE_7_DAYS"

        static let athleteIdKey = "athlete_id"
        static let eventKey = "event"
        static let alertTypeKey = "alert_type"
        static let muteUntilKeyPrefix = "follow_alert_muted_until_"
        static let lastRankPayloadKeyPrefix = "follow_alert_last_rank_payload_"
        static let rankBaselineKnownKeyPrefix = "follow_alert_rank_baseline_known_"
        static let lastDeliveredRankKeyPrefix = "follow_alert_last_delivered_rank_"
    }

    @Published var pendingAthleteRoute: AthleteNotificationRoute?
    private var modelContainer: ModelContainer?
    private var handledNotificationIdentifiers = Set<String>()

    private override init() {
        super.init()
    }

    func configure(modelContainer: ModelContainer? = nil) {
        self.modelContainer = modelContainer
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.setNotificationCategories([makeFollowCategory()])
        if modelContainer != nil {
            syncDeliveredNotifications()
        }
    }

    func syncDeliveredNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { [weak self] notifications in
            notifications.forEach { notification in
                self?.persistFollowAlertIfNeeded(from: notification, markRead: false)
            }
        }
    }

    func muteAthleteFor7Days(athleteId: Int) {
        let muteUntil = Date().addingTimeInterval(60 * 60 * 24 * 7)
        UserDefaults.standard.set(muteUntil.timeIntervalSince1970, forKey: muteKey(for: athleteId))
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let shouldPresent = persistFollowAlertIfNeeded(from: notification, markRead: false)
        completionHandler(shouldPresent ? [.banner, .sound, .badge] : [])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }

        let isViewAthleteAction = response.actionIdentifier == Constants.viewAthleteActionId
        let isDefaultTap = response.actionIdentifier == UNNotificationDefaultActionIdentifier
        _ = persistFollowAlertIfNeeded(from: response.notification, markRead: isViewAthleteAction || isDefaultTap)

        let userInfo = response.notification.request.content.userInfo
        let athleteId = intValue(from: userInfo[Constants.athleteIdKey]) ?? 0
        let event = stringValue(from: userInfo[Constants.eventKey])
        let alertType = stringValue(from: userInfo[Constants.alertTypeKey])

        guard athleteId > 0 else { return }

        if response.actionIdentifier == Constants.mute7DaysActionId {
            muteAthleteFor7Days(athleteId: athleteId)
            return
        }

        guard isViewAthleteAction || isDefaultTap else { return }

        let infoType: String?
        if alertType == "new_result" && isDefaultTap {
            infoType = "Results"
        } else {
            infoType = nil
        }

        DispatchQueue.main.async {
            self.pendingAthleteRoute = AthleteNotificationRoute(
                athleteId: athleteId,
                preferredInfoTypeRawValue: infoType,
                preferredEvent: event
            )
        }
    }

    private func makeFollowCategory() -> UNNotificationCategory {
        let viewAthlete = UNNotificationAction(
            identifier: Constants.viewAthleteActionId,
            title: "View Athlete",
            options: [.foreground]
        )

        let mute = UNNotificationAction(
            identifier: Constants.mute7DaysActionId,
            title: "Mute 7 Days",
            options: []
        )

        return UNNotificationCategory(
            identifier: Constants.followAlertCategoryId,
            actions: [viewAthlete, mute],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
    }

    private func muteKey(for athleteId: Int) -> String {
        "\(Constants.muteUntilKeyPrefix)\(athleteId)"
    }

    @discardableResult
    private func persistFollowAlertIfNeeded(from notification: UNNotification, markRead: Bool) -> Bool {
        let content = notification.request.content
        let userInfo = content.userInfo
        let athleteId = intValue(from: userInfo[Constants.athleteIdKey]) ?? 0
        let alertType = stringValue(from: userInfo[Constants.alertTypeKey])
            ?? (content.categoryIdentifier == Constants.followAlertCategoryId ? "follow_alert" : nil)
            ?? (athleteId > 0 ? "follow_alert" : nil)
        guard let alertType else { return false }

        guard alertType != "digest" else { return false }
        guard let modelContainer else { return false }

        let identifier = notification.request.identifier
        if handledNotificationIdentifiers.contains(identifier) {
            return false
        }
        handledNotificationIdentifiers.insert(identifier)
        if handledNotificationIdentifiers.count > 2_000 {
            handledNotificationIdentifiers.removeAll(keepingCapacity: true)
        }

        let event = stringValue(from: userInfo[Constants.eventKey]) ?? ""
        let athleteName = stringValue(from: userInfo["athlete_name"]) ?? ""
        let title = notification.request.content.title
        let message = notification.request.content.body
        let cutoff = Date().addingTimeInterval(-120)
        
        if alertType == "rank_change" {
            let transition = parseRankTransition(userInfo: userInfo, message: message)
            if shouldSuppressRankChange(
                athleteId: athleteId,
                event: event,
                transition: transition,
                message: message
            ) {
                return false
            }
        }

        Task { @MainActor in
            let context = modelContainer.mainContext
            let recentDescriptor = FetchDescriptor<FollowAlertEvent>(
                predicate: #Predicate {
                    $0.alertType == alertType
                    &&
                    $0.athleteId == athleteId
                    &&
                    $0.message == message
                    &&
                    $0.createdAt >= cutoff
                },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )

            let hasRecentDuplicate = ((try? context.fetch(recentDescriptor)) ?? []).isEmpty == false
            guard !hasRecentDuplicate else {
                if UIApplication.shared.applicationState == .active {
                    await AppBadgeManager.clearBadge()
                } else {
                    await AppBadgeManager.syncUnreadBadgeCount(using: context)
                }
                return
            }

            let eventRecord = FollowAlertEvent(
                athleteId: athleteId,
                athleteName: athleteName,
                event: event,
                alertType: alertType,
                title: title,
                message: message,
                createdAt: Date(),
                isRead: markRead
            )

            context.insert(eventRecord)
            try? context.save()
            if alertType == "rank_change" {
                if let transition = parseRankTransition(userInfo: userInfo, message: message),
                   !transition.current.isEmpty {
                    saveDeliveredRank(transition.current, athleteId: athleteId, event: event)
                }
                saveBaselineKnown(athleteId: athleteId, event: event)
                saveRankPayload(athleteId: athleteId, event: event, message: message)
            }
            if UIApplication.shared.applicationState == .active {
                await AppBadgeManager.clearBadge()
            } else {
                await AppBadgeManager.syncUnreadBadgeCount(using: context)
            }
        }
        
        return true
    }

    private func rankPayloadKey(athleteId: Int, event: String) -> String {
        "\(Constants.lastRankPayloadKeyPrefix)\(athleteId)_\(event)"
    }
    
    private func rankBaselineKey(athleteId: Int, event: String) -> String {
        "\(Constants.rankBaselineKnownKeyPrefix)\(athleteId)_\(event)"
    }
    
    private func lastDeliveredRankKey(athleteId: Int, event: String) -> String {
        "\(Constants.lastDeliveredRankKeyPrefix)\(athleteId)_\(event)"
    }
    
    private func isDuplicateRankPayload(athleteId: Int, event: String, message: String) -> Bool {
        let key = rankPayloadKey(athleteId: athleteId, event: event)
        let lastPayload = UserDefaults.standard.string(forKey: key) ?? ""
        return lastPayload == message
    }
    
    private func saveRankPayload(athleteId: Int, event: String, message: String) {
        let key = rankPayloadKey(athleteId: athleteId, event: event)
        UserDefaults.standard.set(message, forKey: key)
    }
    
    private func isBaselineKnown(athleteId: Int, event: String) -> Bool {
        UserDefaults.standard.bool(forKey: rankBaselineKey(athleteId: athleteId, event: event))
    }
    
    private func saveBaselineKnown(athleteId: Int, event: String) {
        UserDefaults.standard.set(true, forKey: rankBaselineKey(athleteId: athleteId, event: event))
    }
    
    private func lastDeliveredRank(athleteId: Int, event: String) -> String {
        UserDefaults.standard.string(forKey: lastDeliveredRankKey(athleteId: athleteId, event: event)) ?? ""
    }
    
    private func saveDeliveredRank(_ rank: String, athleteId: Int, event: String) {
        UserDefaults.standard.set(rank, forKey: lastDeliveredRankKey(athleteId: athleteId, event: event))
    }
    
    private func shouldSuppressRankChange(
        athleteId: Int,
        event: String,
        transition: (previous: String, current: String)?,
        message: String
    ) -> Bool {
        if let transition {
            if transition.current == "Unranked" {
                return true
            }
            if transition.previous == "Unranked" {
                saveBaselineKnown(athleteId: athleteId, event: event)
                saveDeliveredRank(transition.current, athleteId: athleteId, event: event)
                saveRankPayload(athleteId: athleteId, event: event, message: message)
                return true
            }
            if !isBaselineKnown(athleteId: athleteId, event: event) {
                saveBaselineKnown(athleteId: athleteId, event: event)
                saveDeliveredRank(transition.current, athleteId: athleteId, event: event)
                saveRankPayload(athleteId: athleteId, event: event, message: message)
                return true
            }
            if lastDeliveredRank(athleteId: athleteId, event: event) == transition.current {
                return true
            }
        }
        
        return isDuplicateRankPayload(
            athleteId: athleteId,
            event: event,
            message: message
        )
    }
    
    private func parseRankTransition(
        userInfo: [AnyHashable: Any],
        message: String
    ) -> (previous: String, current: String)? {
        let previousRaw = stringValue(from: userInfo["previous_rank"]) ?? stringValue(from: userInfo["from_rank"])
        let currentRaw = stringValue(from: userInfo["current_rank"]) ?? stringValue(from: userInfo["to_rank"])
        
        if let previousRaw, let currentRaw {
            return (normalizeRank(previousRaw), normalizeRank(currentRaw))
        }
        
        let lower = message.lowercased()
        guard lower.contains("moved from"), lower.contains(" to "), lower.contains(" in ") else {
            return nil
        }
        
        let pattern = #"moved from\s+(.+?)\s+to\s+(.+?)\s+in\s"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let nsMessage = message as NSString
        let range = NSRange(location: 0, length: nsMessage.length)
        guard let match = regex.firstMatch(in: message, options: [], range: range),
              match.numberOfRanges >= 3 else {
            return nil
        }
        
        let previous = nsMessage.substring(with: match.range(at: 1))
        let current = nsMessage.substring(with: match.range(at: 2))
        return (normalizeRank(previous), normalizeRank(current))
    }
    
    private func normalizeRank(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unranked" : trimmed
    }

    private func intValue(from rawValue: Any?) -> Int? {
        if let intValue = rawValue as? Int {
            return intValue
        }
        if let numberValue = rawValue as? NSNumber {
            return numberValue.intValue
        }
        if let stringValue = rawValue as? String {
            return Int(stringValue)
        }
        return nil
    }

    private func stringValue(from rawValue: Any?) -> String? {
        if let stringValue = rawValue as? String {
            return stringValue.isEmpty ? nil : stringValue
        }
        return nil
    }
}
