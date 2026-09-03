//
//  AnalyticsService.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import Foundation
import TelemetryDeck
import UserNotifications

#if os(iOS)
import AppTrackingTransparency
import UIKit
#endif

final class AnalyticsService {
    static let shared = AnalyticsService()

    private let appID = "517FE151-1DA2-42A1-B4B4-3FA05A511A1E"
    private let namespace = "com.thewaymedia"
    private let appGroupDefaults = UserDefaults(suiteName: "group.PaytonSides.RodeoDaily") ?? .standard
    private let installDateKey = "analyticsInstallDate"
    private let hasTrackedLaunchKey = "hasTrackedAnalyticsLaunch"
    private var isConfigured = false

    private init() {}

    func configure() {
        guard !isConfigured else { return }

        let config = TelemetryDeck.Config(appID: appID, namespace: namespace)
        config.defaultSignalPrefix = "rodeo_daily."
        config.defaultParameterPrefix = "rd."
        config.logHandler = nil
        TelemetryDeck.initialize(config: config)
        isConfigured = true
    }

    func track(_ event: AnalyticsEvent) {
        guard event.shouldSendToTelemetryDeck else { return }

        if !isConfigured {
            configure()
        }

        signal(event)
    }

    private var appEnvironmentParameters: [String: String] {
        let launchState = launchState
        var parameters = [
            "app_version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown",
            "build_number": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown",
            "device_type": deviceType,
            "app_locale": Locale.current.identifier,
            "is_first_launch": launchState.isFirstLaunch.analyticsString,
            "days_since_install": String(launchState.daysSinceInstall),
            "install_cohort": launchState.installCohort,
            "os_name": osName,
            "os_version": ProcessInfo.processInfo.operatingSystemVersion.analyticsString,
            "att_status": trackingAuthorizationStatus,
            "preferred_standings_event": appGroupDefaults.string(forKey: "favoriteStandingsEvent") ?? "aa",
            "preferred_results_event": appGroupDefaults.string(forKey: "favoriteResultsEvent") ?? "bb"
        ]

        #if os(iOS)
        parameters["is_ipad_app_on_mac"] = ProcessInfo.processInfo.isiOSAppOnMac.analyticsString
        #endif

        return parameters
    }

    private func signal(_ event: AnalyticsEvent) {
        var parameters = event.parameters.merging(appEnvironmentParameters) { current, _ in
            current
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            parameters["notification_authorization_status"] = settings.authorizationStatus.analyticsString

            DispatchQueue.main.async {
                TelemetryDeck.signal(event.name, parameters: parameters)
            }
        }
    }

    private var launchState: (isFirstLaunch: Bool, daysSinceInstall: Int, installCohort: String) {
        let defaults = UserDefaults.standard
        let now = Date()
        let existingInstallDate = defaults.object(forKey: installDateKey) as? Date
        let isFirstLaunch = !defaults.bool(forKey: hasTrackedLaunchKey) && !hasExistingAppState
        let installDate = existingInstallDate ?? now

        if existingInstallDate == nil {
            defaults.set(installDate, forKey: installDateKey)
        }
        defaults.set(true, forKey: hasTrackedLaunchKey)

        return (
            isFirstLaunch: isFirstLaunch,
            daysSinceInstall: Calendar.current.dateComponents([.day], from: installDate, to: now).day ?? 0,
            installCohort: Self.installCohortFormatter.string(from: installDate)
        )
    }

    private var hasExistingAppState: Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "lastSeenWhatsNewVersion") != nil
            || defaults.object(forKey: "needsATTRequest") != nil
            || appGroupDefaults.object(forKey: "favoriteStandingsEvent") != nil
            || appGroupDefaults.object(forKey: "favoriteResultsEvent") != nil
    }

    private var deviceType: String {
        #if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .mac:
            return "Mac"
        case .tv:
            return "Apple TV"
        case .carPlay:
            return "CarPlay"
        case .vision:
            return "Apple Vision"
        case .unspecified:
            return "unspecified"
        @unknown default:
            return "unknown"
        }
        #elseif os(watchOS)
        return "Apple Watch"
        #else
        return "unknown"
        #endif
    }

    private var trackingAuthorizationStatus: String {
        #if os(iOS)
        return ATTrackingManager.trackingAuthorizationStatus.analyticsString
        #else
        return "unavailable"
        #endif
    }

    private var osName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(watchOS)
        return "watchOS"
        #else
        return "unknown"
        #endif
    }

    private static let installCohortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

enum AnalyticsEvent {
    case appOpened
    case tabViewed(name: String)
    case standingsFilterChanged(event: String, type: String, circuit: String, year: String)
    case resultsFilterChanged(event: String, hasDateRange: Bool)
    case scheduleFilterChanged(hasDateRange: Bool)
    case rodeoDetailViewed(source: String, rodeoID: Int)
    case daysheetViewed(event: String, rounds: Int)
    case athleteBioViewed(source: String)
    case rodeoListingsViewed
    case rodeoListingDetailViewed
    case pastChampionsViewed(event: String)
    case adLifecycle(
        format: String,
        placement: String,
        phase: String,
        adUnitID: String,
        errorDomain: String? = nil,
        errorCode: Int? = nil,
        responseID: String? = nil,
        adapter: String? = nil
    )

    var name: String {
        switch self {
        case .appOpened:
            return "app_opened"
        case .tabViewed:
            return "tab_viewed"
        case .standingsFilterChanged:
            return "standings_filter_changed"
        case .resultsFilterChanged:
            return "results_filter_changed"
        case .scheduleFilterChanged:
            return "schedule_filter_changed"
        case .rodeoDetailViewed:
            return "rodeo_detail_viewed"
        case .daysheetViewed:
            return "daysheet_viewed"
        case .athleteBioViewed:
            return "athlete_bio_viewed"
        case .rodeoListingsViewed:
            return "rodeo_listings_viewed"
        case .rodeoListingDetailViewed:
            return "rodeo_listing_detail_viewed"
        case .pastChampionsViewed:
            return "past_champions_viewed"
        case .adLifecycle:
            return "ad_lifecycle"
        }
    }

    var shouldSendToTelemetryDeck: Bool {
        switch self {
        case .appOpened:
            return true
        case .tabViewed,
             .standingsFilterChanged,
             .resultsFilterChanged,
             .scheduleFilterChanged,
             .rodeoDetailViewed,
             .daysheetViewed,
             .athleteBioViewed,
             .rodeoListingsViewed,
             .rodeoListingDetailViewed,
             .pastChampionsViewed,
             .adLifecycle:
            return false
        }
    }

    var parameters: [String: String] {
        switch self {
        case .appOpened:
            return [:]
        case .tabViewed(let name):
            return ["tab": name]
        case .standingsFilterChanged(let event, let type, let circuit, let year):
            return [
                "event": event,
                "type": type,
                "circuit": circuit,
                "year": year
            ]
        case .resultsFilterChanged(let event, let hasDateRange):
            return [
                "event": event,
                "has_date_range": hasDateRange.analyticsString
            ]
        case .scheduleFilterChanged(let hasDateRange):
            return ["has_date_range": hasDateRange.analyticsString]
        case .rodeoDetailViewed(let source, let rodeoID):
            return [
                "source": source,
                "rodeo_id": String(rodeoID)
            ]
        case .daysheetViewed(let event, let rounds):
            return [
                "event": event,
                "round_count": String(rounds)
            ]
        case .athleteBioViewed(let source):
            return ["source": source]
        case .rodeoListingsViewed:
            return [:]
        case .rodeoListingDetailViewed:
            return [:]
        case .pastChampionsViewed(let event):
            return ["event": event]
        case .adLifecycle(let format, let placement, let phase, let adUnitID, let errorDomain, let errorCode, let responseID, let adapter):
            var parameters = [
                "format": format,
                "placement": placement,
                "phase": phase,
                "ad_unit_id": adUnitID
            ]
            parameters["error_domain"] = errorDomain
            parameters["error_code"] = errorCode.map(String.init)
            parameters["response_id"] = responseID
            parameters["adapter"] = adapter
            return parameters
        }
    }
}

private extension Bool {
    var analyticsString: String {
        self ? "true" : "false"
    }
}

#if os(iOS)
private extension ATTrackingManager.AuthorizationStatus {
    var analyticsString: String {
        switch self {
        case .notDetermined:
            return "not_determined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        @unknown default:
            return "unknown"
        }
    }
}
#endif

private extension UNAuthorizationStatus {
    var analyticsString: String {
        switch self {
        case .notDetermined:
            return "not_determined"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        case .provisional:
            return "provisional"
        case .ephemeral:
            return "ephemeral"
        @unknown default:
            return "unknown"
        }
    }
}

private extension OperatingSystemVersion {
    var analyticsString: String {
        "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
}

extension Tabs {
    var analyticsName: String {
        switch self {
        case .standings:
            return "standings"
        case .results:
            return "results"
        case .schedule:
            return "schedule"
        case .more:
            return "more"
        }
    }
}
