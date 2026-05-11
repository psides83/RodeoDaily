//
//  AppDelegate.swift
//  Rodeo Daily
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FollowNotificationRouter.shared.configure()
        SupabasePushSyncService.shared.registerForRemoteNotifications()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SupabasePushSyncService.shared.registerForRemoteNotifications()
        Task { @MainActor in
            await AppBadgeManager.clearBadge()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs registration succeeded")
        SupabasePushSyncService.shared.updateAPNSToken(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed:", error.localizedDescription)
    }
}
