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
                    ForEach(StandingsEvent.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteStandingsEvent) {
                    WidgetCenter.shared.reloadAllTimelines()
                }

                Picker("Results Event", selection: $favoriteResultsEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteResultsEvent) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
        .navigationTitle("Favorite Events")
    }
}
