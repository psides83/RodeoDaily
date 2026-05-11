//
//  Settings.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext

    @AppStorage("favoriteStandingsEvent",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteStandingsEvent: StandingsEvent = .aa

    @AppStorage("favoriteResultsEvent",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteResultsEvent: Events.CodingKeys = .bb

    var body: some View {
        Form {
            Section("General") {
                NavigationLink {
                    FavoriteEventsSettingsPage(
                        favoriteStandingsEvent: $favoriteStandingsEvent,
                        favoriteResultsEvent: $favoriteResultsEvent
                    )
                } label: {
                    settingsRow(
                        title: NSLocalizedString("Favorite Events", comment: ""),
                        subtitle: NSLocalizedString("Default standings and results events", comment: "")
                    )
                }

                NavigationLink {
                    FavoriteAthletesSettingsPage()
                } label: {
                    settingsRow(
                        title: NSLocalizedString("Favorite Athletes", comment: ""),
                        subtitle: NSLocalizedString("Widget athlete search and management", comment: "")
                    )
                }
            }

            Section("About") {
                NavigationLink {
                    AboutSettingsPage()
                } label: {
                    settingsRow(
                        title: NSLocalizedString("Data Sources & Feedback", comment: ""),
                        subtitle: NSLocalizedString("Credits and contact links", comment: "")
                    )
                }
            }
        }
        .navigationTitle("Settings")
        .task {
            await SupabasePushSyncService.shared.registerDevice()
            await SupabasePushSyncService.shared.syncFollows(modelContext: modelContext)
        }
    }

    private func settingsRow(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
