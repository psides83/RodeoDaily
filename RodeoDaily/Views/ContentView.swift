//
//  ContentView.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/1/23.
//

import SwiftUI

private enum AppRoute: Hashable {
    case athlete(AthleteNotificationRoute)
}

struct ContentView: View {
    @StateObject private var followNotificationRouter = FollowNotificationRouter.shared
    @State private var navigationPath: [AppRoute] = []
    @State private var widgetStandingsEvent: StandingsEvent?
    @Binding private var pendingDeepLinkURL: URL?

    init(pendingDeepLinkURL: Binding<URL?> = .constant(nil)) {
        _pendingDeepLinkURL = pendingDeepLinkURL
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(widgetStandingsEvent: $widgetStandingsEvent)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .athlete(let athleteRoute):
                        BioView(
                            athleteId: athleteRoute.athleteId,
                            preferredInfoTypeRawValue: athleteRoute.preferredInfoTypeRawValue,
                            preferredEvent: athleteRoute.preferredEvent
                        )
                    }
            }
        }
        .tint(.appSecondary)
        .onAppear {
            consumePendingDeepLinkURL()
        }
        .onChange(of: followNotificationRouter.pendingAthleteRoute) { _, route in
            guard let route else { return }
            navigationPath.append(.athlete(route))
            followNotificationRouter.pendingAthleteRoute = nil
        }
        .onChange(of: pendingDeepLinkURL) { _, _ in
            consumePendingDeepLinkURL()
        }
    }

    private func consumePendingDeepLinkURL() {
        guard let pendingDeepLinkURL else { return }
        self.pendingDeepLinkURL = nil
        handleWidgetURL(pendingDeepLinkURL)
    }

    private func handleWidgetURL(_ url: URL) {
        guard url.scheme?.lowercased() == "rodeodaily" else { return }

        let values = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: String]()) { items, queryItem in
                items[queryItem.name] = queryItem.value
            } ?? [:]

        switch url.host?.lowercased() {
        case "athlete":
            guard let athleteValue = values["id"],
                  let athleteId = Int(athleteValue),
                  athleteId > 0 else {
                return
            }

            navigationPath.append(
                .athlete(
                    AthleteNotificationRoute(
                        athleteId: athleteId,
                        preferredInfoTypeRawValue: "Results",
                        preferredEvent: values["event"]
                    )
                )
            )
        case "standings":
            guard let eventValue = values["event"],
                  let event = StandingsEvent(rawValue: eventValue) else {
                return
            }

            navigationPath.removeAll()
            widgetStandingsEvent = event
        default:
            return
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
