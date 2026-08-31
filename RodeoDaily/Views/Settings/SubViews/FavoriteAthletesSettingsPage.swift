import SwiftData
import SwiftUI
import WidgetKit

struct FavoriteAthletesSettingsPage: View {
    @Environment(\.modelContext) var modelContext

    @StateObject var searchModel = SearchSuggetionsApi()
    @StateObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.4)
    @State private var favoriteSaveError: String?
    @State private var selectedSuggestion: SearchResultElement?
    @AppStorage("hasSeenFavoriteAthleteReorderTip") private var hasSeenReorderTip = false

    @Query(sort: \WidgetAthlete.sortOrder) var widgetAthletes: [WidgetAthlete]

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

                if !availableSuggestions.isEmpty {
                    ForEach(availableSuggestions, id: \.id) { suggestion in
                        Button {
                            selectedSuggestion = suggestion
                        } label: {
                            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                                Text(suggestion.term)
                            }
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
                            BioView(athleteId: athlete.athleteId, preferredEvent: athlete.event)
                        } label: {
                            WidgetAthleteCellView(athlete: athlete) {
                                saveFavoriteAthletes()
                            }
                        }
                    }
                    .onDelete(perform: deleteWidgetAthlete)
                    .onMove(perform: moveWidgetAthletes)
                }
            }
        }
        .navigationTitle("Favorite Athletes")
        .toolbar {
            if !widgetAthletes.isEmpty {
                EditButton()
            }
        }
        .onAppear {
            hasSeenReorderTip = true
            normalizeAthleteOrder()
        }
        .onChange(of: search.text) {
            Task {
                await searchModel.getSearchResults(from: search.text)
            }
        }
        .sheet(item: $selectedSuggestion) { suggestion in
            AthleteFavoriteConfirmationView(suggestion: suggestion) { bio in
                saveAthlete(bio, from: suggestion)
                selectedSuggestion = nil
            }
            .presentationDetents([.medium, .large])
        }
        .alert(
            Text("Unable to Add Favorite"),
            isPresented: Binding(
                get: { favoriteSaveError != nil },
                set: { if !$0 { favoriteSaveError = nil } }
            )
        ) {
            Button("OK") {
                favoriteSaveError = nil
            }
        } message: {
            Text(favoriteSaveError ?? "")
        }
    }

    private var availableSuggestions: [SearchResultElement] {
        searchModel.suggestions.filter { suggestion in
            !widgetAthletes.contains { $0.athleteId == suggestion.id }
        }
    }

    private func saveAthlete(_ bio: BioData, from result: SearchResultElement) {
        let athleteName = bio.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard bio.contestantId == result.id, !athleteName.isEmpty else {
            favoriteSaveError = String(
                format: NSLocalizedString("Unable to save %@ because the loaded profile did not match the selected athlete.", comment: ""),
                result.term
            )
            print("[FavoriteAthlete] Rejected favorite ID \(result.id): loaded ID \(bio.contestantId).")
            return
        }

        guard !widgetAthletes.contains(where: { $0.athleteId == bio.contestantId }) else {
            searchFieldFocused = false
            search.text = ""
            return
        }

        let athlete = WidgetAthlete(
            athleteId: bio.contestantId,
            name: athleteName,
            event: bio.topEvent.withTeamRopingConversion,
            events: bio.events,
            sortOrder: nextAthleteSortOrder
        )

        withAnimation {
            modelContext.insert(athlete)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.delete(athlete)
            favoriteSaveError = String(
                format: NSLocalizedString("Unable to save %@ as a favorite. %@", comment: ""),
                athleteName,
                error.localizedDescription
            )
            print("[FavoriteAthlete] SwiftData save failed for athlete ID \(bio.contestantId): \(error.localizedDescription)")
            return
        }

        FavoriteAlert.added(athlete.name).present
        updateWidgets()
        searchFieldFocused = false
        search.text = ""
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
        }

        do {
            try modelContext.save()
            updateWidgets()
        } catch {
            favoriteSaveError = error.localizedDescription
            print("[FavoriteAthlete] Failed deleting favorite athlete: \(error.localizedDescription)")
        }
    }

    private var nextAthleteSortOrder: Int {
        max((widgetAthletes.compactMap(\.sortOrder).max() ?? -1) + 1, widgetAthletes.count)
    }

    private func moveWidgetAthletes(from offsets: IndexSet, to destination: Int) {
        var reorderedAthletes = widgetAthletes
        reorderedAthletes.move(fromOffsets: offsets, toOffset: destination)
        persistAthleteOrder(reorderedAthletes)
    }

    private func normalizeAthleteOrder() {
        persistAthleteOrder(widgetAthletes)
    }

    private func persistAthleteOrder(_ athletes: [WidgetAthlete]) {
        var didChange = false
        for (index, athlete) in athletes.enumerated() where athlete.sortOrder != index {
            athlete.sortOrder = index
            didChange = true
        }

        guard didChange else { return }

        do {
            try modelContext.save()
            updateWidgets()
        } catch {
            favoriteSaveError = error.localizedDescription
            print("[FavoriteAthlete] Failed saving reordered athletes: \(error.localizedDescription)")
        }
    }

    private func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
