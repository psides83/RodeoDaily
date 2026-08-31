//
//  AdMobService.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform

@MainActor
final class AdMobService: ObservableObject {
    static let shared = AdMobService()

    @Published private(set) var canRequestAds = false
    @Published private(set) var isPrivacyOptionsRequired = false

    private var didStartSDK = false
    private var isConfiguring = false

    private init() {}

    func configure(from viewController: UIViewController? = nil) {
        guard !isConfiguring else { return }
        isConfiguring = true

        configureRequestDefaults()

        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

#if DEBUG
        let debugSettings = UMPDebugSettings()
        debugSettings.geography = .disabled
        debugSettings.testDeviceIdentifiers = ["2649F373-DFB5-44E7-8A81-21A3A10AFEF1"]
        parameters.debugSettings = debugSettings
#endif

        Task { @MainActor in
            do {
                try await UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters)
                try await UMPConsentForm.loadAndPresentIfRequired(from: viewController ?? UIApplication.shared.getRootViewController())
                finishConfiguration()
            } catch {
#if DEBUG
                Self.debugLog("Consent flow error: \(error.localizedDescription)")
#endif
                finishConfiguration()
            }
        }
    }

    func presentPrivacyOptions(from viewController: UIViewController? = nil) {
        Task { @MainActor in
            do {
                try await UMPConsentForm.presentPrivacyOptionsForm(from: viewController ?? UIApplication.shared.getRootViewController())
                refreshConsentState()
            } catch {
                refreshConsentState()
            }
        }
    }

#if DEBUG
    func presentAdInspector(from viewController: UIViewController? = nil) {
        GADMobileAds.sharedInstance().presentAdInspector(from: viewController ?? UIApplication.shared.getRootViewController()) { error in
            let message = if let error {
                "Ad Inspector failed: \(error.localizedDescription)"
            } else {
                "Ad Inspector dismissed"
            }

            Task { @MainActor in
                Self.debugLog(message)
            }
        }
    }

    func resetConsentAndReconfigure() {
        canRequestAds = false
        UMPConsentInformation.sharedInstance.reset()
        configure()
    }

    static func debugLog(_ message: String) {
        print("[AdMob] \(message)")
    }
#endif

    private func finishConfiguration() {
        refreshConsentState()

        guard UMPConsentInformation.sharedInstance.canRequestAds else {
            canRequestAds = false
            isConfiguring = false
#if DEBUG
            Self.debugLog("Consent flow finished; canRequestAds=false")
#endif
            return
        }

        startSDKIfNeeded()
        canRequestAds = true
        isConfiguring = false
#if DEBUG
        Self.debugLog("Consent flow finished; canRequestAds=true privacyOptionsRequired=\(isPrivacyOptionsRequired)")
#endif
    }

    private func refreshConsentState() {
        canRequestAds = UMPConsentInformation.sharedInstance.canRequestAds && didStartSDK
        isPrivacyOptionsRequired = UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }

    private func startSDKIfNeeded() {
        guard !didStartSDK else { return }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        didStartSDK = true
    }

    private func configureRequestDefaults() {
        let configuration = GADMobileAds.sharedInstance().requestConfiguration
        configuration.maxAdContentRating = .general

        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            configuration.publisherPrivacyPersonalizationState = .default
        case .denied, .restricted:
            configuration.publisherPrivacyPersonalizationState = .disabled
            configuration.setPublisherFirstPartyIDEnabled(false)
        case .notDetermined:
            configuration.publisherPrivacyPersonalizationState = .default
        @unknown default:
            configuration.publisherPrivacyPersonalizationState = .disabled
            configuration.setPublisherFirstPartyIDEnabled(false)
        }
    }
}

enum AdPlacement {
    case generalAdaptive
    case generalMediumRectangle
    case resultsListInline
    case resultsDetailSection
    case scheduleListInline
    case scheduleDetailBottom
    case standingsListInline
    case athleteBioSection
    case pastChampionsList
    case rodeoListingsList

    var style: BannerAdStyle {
        switch self {
        case .generalAdaptive:
            return .adaptive
        case .generalMediumRectangle,
             .resultsListInline,
             .resultsDetailSection,
             .scheduleListInline,
             .scheduleDetailBottom,
             .standingsListInline,
             .athleteBioSection,
             .pastChampionsList,
             .rodeoListingsList:
            return .mediumRectangle
        }
    }

    var adUnitID: String {
#if DEBUG
        if self == .generalAdaptive {
            return Self.testAdaptiveBannerAdUnitID
        }
        return Self.testBannerAdUnitID
#else
        switch self {
        case .generalAdaptive:
            return Self.productionAdaptiveBannerAdUnitID
        case .generalMediumRectangle:
            return Self.generalMrecAdUnitID
        case .resultsListInline,
             .resultsDetailSection:
            return Self.resultsDetailMrecAdUnitID
        case .scheduleListInline,
             .scheduleDetailBottom:
            return Self.scheduleDetailMrecAdUnitID
        case .standingsListInline:
            return Self.standingsListMrecAdUnitID
        case .athleteBioSection,
             .pastChampionsList,
             .rodeoListingsList:
            return Self.athleteBioMrecAdUnitID
        }
#endif
    }

    var nativeAdUnitID: String {
#if DEBUG
        return Self.testNativeAdUnitID
#else
        switch self {
        case .resultsListInline:
            return Self.resultsListNativeAdUnitID
        case .scheduleListInline:
            return Self.scheduleListNativeAdUnitID
        case .generalAdaptive,
             .generalMediumRectangle,
             .resultsDetailSection,
             .scheduleDetailBottom,
             .standingsListInline,
             .athleteBioSection,
             .pastChampionsList,
             .rodeoListingsList:
            return Self.resultsListNativeAdUnitID
        }
#endif
    }

    private static let productionAdaptiveBannerAdUnitID = "ca-app-pub-4837925489125062/9230424503"
    private static let generalMrecAdUnitID = "ca-app-pub-4837925489125062/7546946977"
    private static let resultsDetailMrecAdUnitID = "ca-app-pub-4837925489125062/5279647378"
    private static let scheduleDetailMrecAdUnitID = "ca-app-pub-4837925489125062/7219643913"
    private static let standingsListMrecAdUnitID = "ca-app-pub-4837925489125062/6021883402"
    private static let athleteBioMrecAdUnitID = "ca-app-pub-4837925489125062/9825397043"
    private static let resultsListNativeAdUnitID = "ca-app-pub-4837925489125062/4692204530"
    private static let scheduleListNativeAdUnitID = "ca-app-pub-4837925489125062/3643132078"
    private static let testAdaptiveBannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    private static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private static let testNativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"
}
