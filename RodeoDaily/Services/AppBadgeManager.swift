//
//  AppBadgeManager.swift
//  Rodeo Daily
//

import SwiftData
import UserNotifications

enum AppBadgeManager {
    @MainActor
    static func clearBadge() async {
        try? await UNUserNotificationCenter.current().setBadgeCount(0)
    }

    @MainActor
    static func syncUnreadBadgeCount(using modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<FollowAlertEvent>(
            predicate: #Predicate { $0.isRead == false }
        )
        let unreadCount = ((try? modelContext.fetch(descriptor)) ?? []).count

        try? await UNUserNotificationCenter.current().setBadgeCount(unreadCount)
    }
}
