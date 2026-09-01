//
//  AthletesView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/24/24.
//

import SwiftData
import SwiftUI
import WidgetKit

struct AthletesView: View {
    @Environment(\.modelContext) private var modelContext
    private let initialSearchText: String
    @StateObject private var searchModel = SearchSuggetionsApi()
    @StateObject private var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.4)
    @FocusState private var searchFieldFocused: Bool
    @State private var favoriteSaveError: String?
    @State private var selectedSuggestion: SearchResultElement?
    @AppStorage("hasSeenFavoriteAthleteReorderTip") private var hasSeenReorderTip = false

    @Query(sort: \WidgetAthlete.sortOrder) var widgetAthletes: [WidgetAthlete]
    
    init(searchText: String = "") {
        self.initialSearchText = searchText
        
        //        _widgetAthletes = Query(filter: #Predicate { athlete in
        //            if searchText.isEmpty {
        //                true
        //            } else {
        //                athlete.name.localizedStandardContains(searchText)
        //            }
        //        })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                headerCard
                
                if !availableSuggestions.isEmpty {
                    suggestionsCard
                } else if searchModel.loading && !search.text.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .hSpacing(.center)
                        .appCardStyle()
                }
            
                if widgetAthletes.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Text("No Athletes")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appPrimary)
                            
                            Image.cowboy
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 72, height:  72)
                                .foregroundStyle(Color.appPrimary)
                            
                        }
                    } description: {
                        Text("Add athletes to favorites from the settings tab. These athletes will be available to add widgets to your home screen.")
                    }
                } else {
                    LazyVStack(spacing: AppSpace.md) {
                        ForEach(Array(widgetAthletes.enumerated()), id: \.element.id) { index, athlete in
                            if shouldShowFavoriteAthleteAd(afterItemAt: index) {
                                BannerAd(placement: .athleteBioSection)
                            }

                            NavigationLink {
                                BioView(athleteId: athlete.athleteId, preferredEvent: athlete.event)
                            } label: {
                                AthleteCellView(athlete: athlete)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                BannerAd(placement: .athleteBioSection)
                    .frame(height: 250)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    FavoriteAthletesSettingsPage()
                } label: {
                    Label("Manage", systemImage: "slider.horizontal.3")
                }
            }
        }
        .onAppear {
            normalizeAthleteOrder()
            if search.text.isEmpty && !initialSearchText.isEmpty {
                search.text = initialSearchText
            }
        }
        .onChange(of: search.text) { _, newValue in
            Task {
                await searchModel.getSearchResults(from: newValue)
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

    private func shouldShowFavoriteAthleteAd(afterItemAt index: Int) -> Bool {
        widgetAthletes.count > 20 && index > 0 && index.isMultiple(of: 10)
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text("Favorite Athletes")
                .foregroundColor(.appPrimary)
                .font(.appSectionTitle)
                .fontWeight(.bold)
            
            Text("\(widgetAthletes.count) athletes")
                .foregroundColor(.appSecondary)
                .font(.appBodyStrong)
            
            Text("Open an athlete to view bio, results, and follow updates.")
                .foregroundColor(.appTertiary)
                .font(.appCaption)

            Text("Search below to add athletes to your favorites list.")
                .foregroundColor(.appTertiary)
                .font(.appCaption)

            if widgetAthletes.count > 1 && !hasSeenReorderTip {
                Divider()

                HStack(spacing: AppSpace.sm) {
                    Text("Use Manage above to reorder athletes.")
                        .foregroundColor(.appTertiary)
                        .font(.appCaption)

                    Spacer()

                    NavigationLink {
                        FavoriteAthletesSettingsPage()
                    } label: {
                        Text("Open")
                            .font(.appCaptionStrong)
                            .foregroundStyle(Color.appSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: AppSpace.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appSecondary)
                
                TextField(
                    "Athlete Name",
                    text: $search.text,
                    prompt: Text("Search athletes to add to favorites")
                )
                .focused($searchFieldFocused)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                
                if !search.text.isEmpty {
                    Button {
                        search.text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpace.md)
            .padding(.vertical, AppSpace.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(widgetAthletes.isEmpty ? Color.appSecondary.opacity(0.08) : Color.appBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(
                        widgetAthletes.isEmpty ? Color.appSecondary.opacity(0.35) : Color.appTertiary.opacity(0.25),
                        lineWidth: AppStroke.hairline
                    )
            )
        }
        .appCardStyle()
    }

    private var suggestionsCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            Text("Tap an athlete to add to favorites")
                .font(.appCaptionStrong)
                .foregroundColor(.appTertiary)
            
            ForEach(availableSuggestions, id: \.id) { suggestion in
                Button {
                    selectedSuggestion = suggestion
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpace.xxs) {
                            Text(suggestion.term)
                                .font(.appBodyStrong)
                                .foregroundColor(.appPrimary)
                                .lineSpacing(2)
                        }
                        Spacer()
                        Image(systemName: "plus.circle")
                            .foregroundColor(.appSecondary)
                    }
                    .padding(.vertical, AppSpace.xs)
                }
                .buttonStyle(.plain)

                if suggestion.id != availableSuggestions.last?.id {
                    Divider()
                }
            }
        }
        .appCardStyle()
    }

    private var sortedSuggestions: [SearchResultElement] {
        searchModel.suggestions.sorted { lhs, rhs in
            let left = lhs.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let right = rhs.term.trimmingCharacters(in: .whitespacesAndNewlines)

            let leftParts = left.split(separator: " ", omittingEmptySubsequences: true)
            let rightParts = right.split(separator: " ", omittingEmptySubsequences: true)

            let leftFirst = leftParts.first.map(String.init) ?? left
            let rightFirst = rightParts.first.map(String.init) ?? right

            if leftFirst.localizedCaseInsensitiveCompare(rightFirst) == .orderedSame {
                return left.localizedCaseInsensitiveCompare(right) == .orderedAscending
            }

            return leftFirst.localizedCaseInsensitiveCompare(rightFirst) == .orderedAscending
        }
    }

    private var availableSuggestions: [SearchResultElement] {
        sortedSuggestions.filter { suggestion in
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

        WidgetCenter.shared.reloadAllTimelines()
        FavoriteAlert.added(athlete.name).present
        searchFieldFocused = false
        search.text = ""
    }

    private var nextAthleteSortOrder: Int {
        max((widgetAthletes.compactMap(\.sortOrder).max() ?? -1) + 1, widgetAthletes.count)
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
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            favoriteSaveError = error.localizedDescription
            print("[FavoriteAthlete] Failed saving reordered athletes: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AthletesView()
}
