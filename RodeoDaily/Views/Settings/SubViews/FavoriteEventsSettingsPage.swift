import SwiftUI
import WidgetKit

struct FavoriteEventsSettingsPage: View {
    @Binding var favoriteStandingsEvent: StandingsEvent
    @Binding var favoriteResultsEvent: Events.CodingKeys

    var body: some View {
        Form {
            Section(
                header: Text(NSLocalizedString("Favorite Events", comment: "")),
                footer: Text(NSLocalizedString("Used to populate lock screen widgets and defaults when the app opens.", comment: ""))
            ) {
                Picker("Standings Event", selection: $favoriteStandingsEvent) {
                    ForEach(StandingsEvent.standingsFilterEvents, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteStandingsEvent) {
                    favoriteStandingsEvent = favoriteStandingsEvent.normalizedForStandingsFilter
                    FavoriteEventSettingsSync.shared.updateStandingsEvent(favoriteStandingsEvent)
                    WidgetCenter.shared.reloadAllTimelines()
                }

                Picker("Results Event", selection: $favoriteResultsEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteResultsEvent) {
                    FavoriteEventSettingsSync.shared.updateResultsEvent(favoriteResultsEvent)
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
        .onAppear {
            favoriteStandingsEvent = favoriteStandingsEvent.normalizedForStandingsFilter
        }
        .navigationTitle("Favorite Events")
    }
}
