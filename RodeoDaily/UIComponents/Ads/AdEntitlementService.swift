//
//  AdEntitlementService.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import Foundation

@MainActor
final class AdEntitlementService: ObservableObject {
    static let shared = AdEntitlementService()

    @Published private(set) var isAdFreeSubscriber: Bool

    private let defaults: UserDefaults
    private let adFreeKey = "isAdFreeSubscriber"
#if DEBUG
    private let debugAdFreeOverrideKey = "debugIsAdFreeSubscriber"
#endif

    private init(defaults: UserDefaults = UserDefaults(suiteName: "group.PaytonSides.RodeoDaily") ?? .standard) {
        self.defaults = defaults
        self.isAdFreeSubscriber = Self.readEntitlement(from: defaults)
#if DEBUG
        AdMobService.debugLog("Ad entitlement loaded isAdFreeSubscriber=\(isAdFreeSubscriber) productionValue=\(defaults.bool(forKey: adFreeKey)) debugOverride=\(defaults.object(forKey: debugAdFreeOverrideKey) as? Bool ?? false)")
#endif
    }

    var canShowAds: Bool {
        !isAdFreeSubscriber
    }

    func refresh() {
        isAdFreeSubscriber = Self.readEntitlement(from: defaults)
    }

#if DEBUG
    func setDebugAdFree(_ isAdFree: Bool) {
        defaults.set(isAdFree, forKey: debugAdFreeOverrideKey)
        refresh()
    }

    func clearDebugAdFreeOverride() {
        defaults.removeObject(forKey: debugAdFreeOverrideKey)
        refresh()
    }

    func resetStoredAdFreeEntitlement() {
        defaults.removeObject(forKey: adFreeKey)
        defaults.removeObject(forKey: debugAdFreeOverrideKey)
        refresh()
    }
#endif

    private static func readEntitlement(from defaults: UserDefaults) -> Bool {
#if DEBUG
        if let debugValue = defaults.object(forKey: "debugIsAdFreeSubscriber") as? Bool {
            return debugValue
        }
        return false
#else
        return false
#endif
    }
}
