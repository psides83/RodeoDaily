//
//  AppBadgeManager.swift
//  Rodeo Daily
//

import SwiftData
import UIKit
import UserNotifications

enum AppBadgeManager {
    @MainActor
    static func clearBadge() async {
        if #available(iOS 17.0, *) {
            try? await UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    @MainActor
    static func syncUnreadBadgeCount(using modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<FollowAlertEvent>(
            predicate: #Predicate { $0.isRead == false }
        )
        let unreadCount = ((try? modelContext.fetch(descriptor)) ?? []).count

        if #available(iOS 17.0, *) {
            try? await UNUserNotificationCenter.current().setBadgeCount(unreadCount)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }
    }
}
