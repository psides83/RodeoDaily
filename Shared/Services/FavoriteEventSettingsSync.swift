//
//  FavoriteEventSettingsSync.swift
//  RodeoDaily
//
//  Created by Codex on 5/16/26.
//

import Foundation
import WatchConnectivity

final class FavoriteEventSettingsSync: NSObject, WCSessionDelegate {
    static let shared = FavoriteEventSettingsSync()

    static let favoriteStandingsEventKey = "favoriteStandingsEvent"
    static let favoriteResultsEventKey = "favoriteResultsEvent"
    static let favoriteStandingsEventUpdatedAtKey = "favoriteStandingsEventUpdatedAt"
    static let favoriteResultsEventUpdatedAtKey = "favoriteResultsEventUpdatedAt"

    private let defaults: UserDefaults
    private var isConfigured = false

    private override init() {
        #if os(watchOS)
        defaults = UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch") ?? .standard
        #else
        defaults = UserDefaults(suiteName: "group.PaytonSides.RodeoDaily") ?? .standard
        #endif
        super.init()
        migrateLegacyWatchKeysIfNeeded()
        seedTimestampsForExistingSettingsIfNeeded()
    }

    func configure() {
        guard WCSession.isSupported(), !isConfigured else { return }
        isConfigured = true
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func syncCurrentSettings() {
        configure()
        sendCurrentSettings()
    }

    func updateStandingsEvent(_ event: StandingsEvent) {
        defaults.set(event.rawValue, forKey: Self.favoriteStandingsEventKey)
        defaults.set(Date().timeIntervalSince1970, forKey: Self.favoriteStandingsEventUpdatedAtKey)
        sendCurrentSettings()
    }

    func updateResultsEvent(_ event: Events.CodingKeys) {
        defaults.set(event.rawValue, forKey: Self.favoriteResultsEventKey)
        defaults.set(Date().timeIntervalSince1970, forKey: Self.favoriteResultsEventUpdatedAtKey)
        sendCurrentSettings()
    }

    private func sendCurrentSettings() {
        guard WCSession.isSupported() else { return }

        let payload: [String: Any] = [
            Self.favoriteStandingsEventKey: standingsEvent.rawValue,
            Self.favoriteResultsEventKey: resultsEvent.rawValue,
            Self.favoriteStandingsEventUpdatedAtKey: defaults.double(forKey: Self.favoriteStandingsEventUpdatedAtKey),
            Self.favoriteResultsEventUpdatedAtKey: defaults.double(forKey: Self.favoriteResultsEventUpdatedAtKey)
        ]

        do {
            try WCSession.default.updateApplicationContext(payload)
        } catch {
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: nil, errorHandler: nil)
            }
        }
    }

    private var standingsEvent: StandingsEvent {
        let rawValue = defaults.string(forKey: Self.favoriteStandingsEventKey) ?? StandingsEvent.aa.rawValue
        return StandingsEvent(rawValue: rawValue) ?? .aa
    }

    private var resultsEvent: Events.CodingKeys {
        let rawValue = defaults.string(forKey: Self.favoriteResultsEventKey) ?? Events.CodingKeys.bb.rawValue
        return Events.CodingKeys(rawValue: rawValue) ?? .bb
    }

    private func migrateLegacyWatchKeysIfNeeded() {
        #if os(watchOS)
        if defaults.object(forKey: Self.favoriteStandingsEventKey) == nil,
           let legacyStandingsRaw = defaults.string(forKey: "standingsWatchEvent"),
           StandingsEvent(rawValue: legacyStandingsRaw) != nil {
            defaults.set(legacyStandingsRaw, forKey: Self.favoriteStandingsEventKey)
        }

        if defaults.object(forKey: Self.favoriteResultsEventKey) == nil,
           let legacyResultsRaw = defaults.string(forKey: "resultsWatchEvent"),
           Events.CodingKeys(rawValue: legacyResultsRaw) != nil {
            defaults.set(legacyResultsRaw, forKey: Self.favoriteResultsEventKey)
        }
        #endif
    }

    private func seedTimestampsForExistingSettingsIfNeeded() {
        #if os(iOS)
        let now = Date().timeIntervalSince1970

        if defaults.object(forKey: Self.favoriteStandingsEventKey) != nil,
           defaults.object(forKey: Self.favoriteStandingsEventUpdatedAtKey) == nil {
            defaults.set(now, forKey: Self.favoriteStandingsEventUpdatedAtKey)
        }

        if defaults.object(forKey: Self.favoriteResultsEventKey) != nil,
           defaults.object(forKey: Self.favoriteResultsEventUpdatedAtKey) == nil {
            defaults.set(now, forKey: Self.favoriteResultsEventUpdatedAtKey)
        }
        #endif
    }

    private func apply(_ payload: [String: Any]) {
        if let standingsRaw = payload[Self.favoriteStandingsEventKey] as? String,
           StandingsEvent(rawValue: standingsRaw) != nil {
            if shouldApplyRemoteValue(
                remoteUpdatedAt: payload[Self.favoriteStandingsEventUpdatedAtKey] as? Double,
                localValueKey: Self.favoriteStandingsEventKey,
                localUpdatedAtKey: Self.favoriteStandingsEventUpdatedAtKey
            ) {
                defaults.set(standingsRaw, forKey: Self.favoriteStandingsEventKey)
                if let remoteUpdatedAt = payload[Self.favoriteStandingsEventUpdatedAtKey] as? Double {
                    defaults.set(remoteUpdatedAt, forKey: Self.favoriteStandingsEventUpdatedAtKey)
                }
            }
        }

        if let resultsRaw = payload[Self.favoriteResultsEventKey] as? String,
           Events.CodingKeys(rawValue: resultsRaw) != nil {
            if shouldApplyRemoteValue(
                remoteUpdatedAt: payload[Self.favoriteResultsEventUpdatedAtKey] as? Double,
                localValueKey: Self.favoriteResultsEventKey,
                localUpdatedAtKey: Self.favoriteResultsEventUpdatedAtKey
            ) {
                defaults.set(resultsRaw, forKey: Self.favoriteResultsEventKey)
                if let remoteUpdatedAt = payload[Self.favoriteResultsEventUpdatedAtKey] as? Double {
                    defaults.set(remoteUpdatedAt, forKey: Self.favoriteResultsEventUpdatedAtKey)
                }
            }
        }
    }

    private func shouldApplyRemoteValue(
        remoteUpdatedAt: Double?,
        localValueKey: String,
        localUpdatedAtKey: String
    ) -> Bool {
        guard defaults.object(forKey: localValueKey) != nil else { return true }
        guard let remoteUpdatedAt else { return false }

        let localUpdatedAt = defaults.double(forKey: localUpdatedAtKey)
        return remoteUpdatedAt >= localUpdatedAt
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else { return }
        apply(session.receivedApplicationContext)
        #if os(iOS)
        sendCurrentSettings()
        #endif
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        apply(applicationContext)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        apply(message)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
