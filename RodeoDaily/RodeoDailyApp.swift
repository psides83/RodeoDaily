//
//  Rodeo_DailyApp.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/1/23.
//

import SwiftData
import SwiftUI

@main
struct RodeoDailyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var attHandler = ATTHandler()
    @StateObject private var followNotificationRouter = FollowNotificationRouter.shared
    private let appModelContainer: ModelContainer
    @Environment(\.scenePhase) private var scenePhase
    @State private var shouldShowReviewPrompt = false
    @State private var didTrackAppOpen = false
    @State private var pendingDeepLinkURL: URL?

    @AppStorage("needsATTRequest") var needsATTRequest = true
    @AppStorage("lastSeenWhatsNewVersion") var lastSeenWhatsNewVersion = ""
    private let currentWhatsNewVersion = "2.4.0"
    
    init() {
        AnalyticsService.shared.configure()

        do {
            appModelContainer = try Self.makeModelContainer()
        } catch {
            fatalError("Unable to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if attHandler.status == .notDetermined && needsATTRequest {
                    ATTRequestView()
                } else if lastSeenWhatsNewVersion != currentWhatsNewVersion {
                    WhatsNewOnboardingView(version: currentWhatsNewVersion)
                } else {
                    ContentView(pendingDeepLinkURL: $pendingDeepLinkURL)
                }
            }
            .onAppear {
                if !didTrackAppOpen {
                    AnalyticsService.shared.track(.appOpened)
                    didTrackAppOpen = true
                }

                attHandler.checkATTStatus()
                followNotificationRouter.configure(modelContainer: appModelContainer)
                FavoriteEventSettingsSync.shared.syncCurrentSettings()
                SupabasePushSyncService.shared.registerForRemoteNotificationsIfAuthorized()
                Task {
                    await SupabasePushSyncService.shared.registerDevice()
                    await AppBadgeManager.clearBadge()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task { @MainActor in
                    followNotificationRouter.syncDeliveredNotifications()
                    await AppBadgeManager.clearBadge()
                    maybeTriggerReviewPrompt()
                }
            }
            .alert(
                Text(NSLocalizedString("Enjoying Rodeo Daily?", comment: "")),
                isPresented: $shouldShowReviewPrompt
            ) {
                Button(NSLocalizedString("Rate App", comment: "")) {
                    AppReviewPromptManager.shared.markUserRated()
                    AppReviewPromptManager.shared.requestInAppReviewIfPossible()
                }
                Button(NSLocalizedString("Send Feedback", comment: "")) {
                    AppReviewPromptManager.shared.openFeedbackEmail()
                }
                Button(NSLocalizedString("Not Now", comment: ""), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("Your feedback helps us improve Rodeo Daily for every fan.", comment: ""))
            }
            .onOpenURL { url in
                pendingDeepLinkURL = url
            }
        }
        .modelContainer(appModelContainer)
    }

    @MainActor
    private func maybeTriggerReviewPrompt() {
        let isBlockingFlowVisible = (attHandler.status == .notDetermined && needsATTRequest)
            || (lastSeenWhatsNewVersion != currentWhatsNewVersion)
        guard isBlockingFlowVisible == false else { return }

        shouldShowReviewPrompt = AppReviewPromptManager.shared.registerSessionAndShouldPrompt()
    }

    private static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema([WidgetAthlete.self, FollowedAthlete.self, FollowAlertEvent.self])
        let configuration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private static var sharedStoreURL: URL {
        let appGroupId = "group.PaytonSides.RodeoDaily"
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else {
            return URL.documentsDirectory.appending(path: "default.store")
        }

        let storeDirectory = groupURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        try? FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
        return storeDirectory.appendingPathComponent("default.store")
    }

}
