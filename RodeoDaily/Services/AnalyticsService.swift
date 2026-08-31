//
//  AnalyticsService.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import Foundation
import TelemetryDeck

final class AnalyticsService {
    static let shared = AnalyticsService()

    private let appID = "517FE151-1DA2-42A1-B4B4-3FA05A511A1E"
    private let namespace = "com.thewaymedia"
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
        if !isConfigured {
            configure()
        }

        TelemetryDeck.signal(event.name, parameters: event.parameters)
    }
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
