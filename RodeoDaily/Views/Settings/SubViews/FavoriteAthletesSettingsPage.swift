import SwiftData
import SwiftUI
import WidgetKit

struct FavoriteAthletesSettingsPage: View {
    @Environment(\.modelContext) var modelContext

    @StateObject var searchModel = SearchSuggetionsApi()
    @StateObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.4)

    @Query var widgetAthletes: [WidgetAthlete]

    @FocusState var searchFieldFocused: Bool

    var body: some View {
        Form {
            Section(
                header: Text(NSLocalizedString("Athlete Search", comment: "")),
                footer: Text(NSLocalizedString("Search for an athlete to add to your favorite widget list.", comment: ""))
            ) {
                TextField(
                    "Athlete Name",
                    text: $search.text,
                    prompt: Text("Search athletes to add favorite")
                )
                .focused($searchFieldFocused)

                if !searchModel.suggestions.isEmpty {
                    ForEach(searchModel.suggestions, id: \.id) { suggestion in
                        Button {
                            setAthlete(from: suggestion)
                        } label: {
                            Text(suggestion.term)
                        }
                    }
                } else if searchModel.loading && !search.text.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .hSpacing(.center)
                }
            }

            if !widgetAthletes.isEmpty {
                Section(
                    header: Label(NSLocalizedString("Favorite Athlete Widget", comment: ""), systemImage: "star.fill"),
                    footer: VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("* Unfortunately, setting a Favorite Athlete for Barrel Racing and Breakaway Roping is unavailable at this time.", comment: ""))
                        Text(NSLocalizedString("* **Note:** Long press on the athlete name to change the event used in the widget.", comment: ""))
                    }
                ) {
                    ForEach(widgetAthletes, id: \.id) { athlete in
                        NavigationLink {
                            BioView(athleteId: athlete.athleteId)
                        } label: {
                            WidgetAthleteCellView(athlete: athlete) {
                                saveFavoriteAthletes()
                            }
                        }
                    }
                    .onDelete(perform: deleteWidgetAthlete)
                }
            }
        }
        .navigationTitle("Favorite Athletes")
        .onChange(of: search.text) {
            Task {
                await searchModel.getSearchResults(from: search.text)
            }
        }
    }

    private func setAthlete(from result: SearchResultElement) {
        Task {
            let bioApi = BioViewModel()
            await bioApi.getBio(for: result.id)
            let bio = bioApi.bio

            let athlete = WidgetAthlete(
                athleteId: bio.contestantId,
                name: bio.name,
                event: bio.topEvent.withTeamRopingConversion,
                events: bio.events
            )

            withAnimation {
                modelContext.insert(athlete)
                FavoriteAlert.added(athlete.name).present
                updateWidgets()
                searchFieldFocused = false
                search.text = ""
            }
        }
    }

    private func saveFavoriteAthletes() {
        try? modelContext.save()
        updateWidgets()
    }

    private func deleteWidgetAthlete(at offsets: IndexSet) {
        for offset in offsets {
            let athlete = widgetAthletes[offset]
            modelContext.delete(athlete)
            FavoriteAlert.removed(athlete.name).present
            updateWidgets()
        }
    }

    private func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
