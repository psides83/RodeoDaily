//
//  Settings.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    
    @StateObject var viewModel = AthletesApi()
    @StateObject var searchModel = SearchSuggetionsApi()
    @StateObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.4)
    
    @Query var widgetAthletes: [WidgetAthlete]
    
    @AppStorage("favoriteStandingsEvent",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteStandingsEvent: StandingsEvent = .aa
    
    @AppStorage("favoriteResultsEvent",
                store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily"))
    var favoriteResultsEvent: Events.CodingKeys = .bb
    
    @FocusState var searchFieldFocused: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Favorite Events"),
                    footer: Text("The selected events will be used to populate the lock screen widget data and load in the respective tab when the app opens.")) {
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
            
            athleteSearchSection
            
            if !widgetAthletes.isEmpty {
                Section(header: favoritesSection.header, footer: favoritesSection.footer) {
                    ForEach(widgetAthletes, id: \.id) { athlete in
                        NavigationLink {
                            BioView(athleteId: athlete.athleteId)
                        } label: {
                            WidgetAthleteCellView(athlete: athlete, onChange: saveFavoriteAthletes)
                        }
                    }
                    .onDelete(perform: deleteWidgetAthlete)
                }
            }
            
            Section(footer: contactFooter) {}
        }
        .navigationTitle("Settings")
        .onChange(of: search.text) {
            Task {
                await searchModel.getSearchResults(from: search.text)
            }
        }
    }
    
    var contactFooter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Link(
                destination: URL(string: "thewaymediaco@gmail.com")!) {
                    Label("Submit Feedback", systemImage: "envelope")
                        .font(.caption)
                }
            
            Link(
                "Cowboy Icon provided by IconScout",
                destination: URL(string: "https://iconscout.com/icons/cowboy")!)
            .font(.caption)
        }
        .tint(.appPrimary)
    }
    
    var athleteSearchSection: some View {
        Section(
            header: Text("Athlete Search"),
            footer: Text("Search for an athlete to add to your list of favorites for the favorite athlete widget.")
        ) {
            TextField(
                "Athlete Name",
                text: $search.text,
                prompt: Text("Search athletes to add favorite")
            )
            .focused($searchFieldFocused)
            
            if searchModel.suggestions.count != 0 {
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
    }
    
    var favoritesSection: (header: some View, footer: some View) {
        return (
            header: HStack {
                Label("Favorite Athlete Widget", systemImage: "star.fill")
                    .foregroundColor(.appSecondary)
            },
            footer:
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("* Unfortunately, setting a Favorite Athlete for Barrel Reacing and Breakaway Roping is unvailavble at this time.")
                    
                    Text("* **Note:** Long press on the athlete name to change the event used in the widget.")
                }
            
        )
    }
    
    func setAthlete(from result: SearchResultElement) {
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
    
    func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
