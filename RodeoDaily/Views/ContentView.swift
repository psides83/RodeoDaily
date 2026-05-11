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

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView()
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
        .onChange(of: followNotificationRouter.pendingAthleteRoute) { _, route in
            guard let route else { return }
            navigationPath.append(.athlete(route))
            followNotificationRouter.pendingAthleteRoute = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
