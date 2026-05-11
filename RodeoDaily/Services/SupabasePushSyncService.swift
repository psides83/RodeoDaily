//
//  SupabasePushSyncService.swift
//  Rodeo Daily
//

import SwiftData
import UIKit
import UserNotifications

final class SupabasePushSyncService {
    static let shared = SupabasePushSyncService()

    private enum Constants {
        static let projectURL = SupabaseConfig.projectURL
        static let publishableKey = SupabaseConfig.publishableKey
        static let installationIdKey = "supabase_installation_id"
        static let apnsTokenKey = "apns_device_token_hex"
        static let mutedUntilKeyPrefix = "follow_alert_muted_until_"
    }

    private init() {}

    var installationId: String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: Constants.installationIdKey), !existing.isEmpty {
            return existing
        }

        let created = UUID().uuidString
        defaults.set(created, forKey: Constants.installationIdKey)
        return created
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func registerForRemoteNotificationsIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                return
            }

            self.registerForRemoteNotifications()
        }
    }

    func updateAPNSToken(deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(token, forKey: Constants.apnsTokenKey)

        Task {
            await registerDevice()
        }
    }

    func registerDevice() async {
        let defaults = UserDefaults.standard
        let payload: [String: Any] = [
            "installation_id": installationId,
            "apns_token": defaults.string(forKey: Constants.apnsTokenKey) as Any,
            "app_bundle_id": Bundle.main.bundleIdentifier ?? "PaytonSides.RodeoDaily",
            "timezone": TimeZone.current.identifier,
            "locale": Locale.current.identifier,
            "push_enabled": defaults.object(forKey: "follow_alert_push_enabled") as? Bool ?? true,
            "quiet_hours_enabled": defaults.object(forKey: "follow_alert_quiet_hours_enabled") as? Bool ?? true,
            "quiet_start_hour": defaults.object(forKey: "follow_alert_quiet_start_hour") as? Int ?? 22,
            "quiet_end_hour": defaults.object(forKey: "follow_alert_quiet_end_hour") as? Int ?? 7,
            "daily_cap_enabled": defaults.object(forKey: "follow_alert_daily_cap_enabled") as? Bool ?? true,
            "daily_cap_count": defaults.object(forKey: "follow_alert_daily_cap_count") as? Int ?? 6,
            "digest_enabled": defaults.object(forKey: "follow_alert_digest_enabled") as? Bool ?? true
        ]

        await post(function: "register-device", payload: payload)
    }

    @MainActor
    func syncFollows(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<FollowedAthlete>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        let followed = (try? modelContext.fetch(descriptor)) ?? []
        let defaults = UserDefaults.standard

        var unique = [String: FollowedAthlete]()
        followed.forEach { athlete in
            let key = "\(athlete.athleteId)-\(athlete.event)"
            if unique[key] == nil {
                unique[key] = athlete
            }
        }

        let follows = unique.values.map { athlete -> [String: Any] in
            let mutedKey = "\(Constants.mutedUntilKeyPrefix)\(athlete.athleteId)"
            let mutedTimestamp = defaults.double(forKey: mutedKey)
            let mutedUntilISO: String? = mutedTimestamp > Date().timeIntervalSince1970
                ? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: mutedTimestamp))
                : nil

            return [
                "athlete_id": athlete.athleteId,
                "athlete_name": athlete.name,
                "event": athlete.event,
                "alert_rank_enabled": defaults.object(forKey: "follow_alert_rank_enabled") as? Bool ?? true,
                "alert_result_enabled": defaults.object(forKey: "follow_alert_result_enabled") as? Bool ?? true,
                "alert_rodeo_result_enabled": defaults.object(forKey: "follow_alert_rodeo_result_enabled") as? Bool ?? true,
                "muted_until": mutedUntilISO as Any
            ]
        }

        let payload: [String: Any] = [
            "installation_id": installationId,
            "follows": follows
        ]

        await post(function: "sync-follows", payload: payload)
    }

    private func post(function: String, payload: [String: Any]) async {
        guard let url = URL(string: "\(Constants.projectURL)/functions/v1/\(function)") else { return }
        guard JSONSerialization.isValidJSONObject(payload) else { return }
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Constants.publishableKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1

            if code >= 300 {
                let bodyText = String(data: data, encoding: .utf8) ?? "<empty>"
                print("Supabase \(function) failed [\(code)]: \(bodyText)")
            } else {
                print("Supabase \(function) ok [\(code)]")
            }
        } catch {
            print("Supabase push sync failed:", error.localizedDescription)
        }
    }
}
