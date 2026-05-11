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

    @Query var widgetAthletes: [WidgetAthlete]
    
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
                
                if !searchModel.suggestions.isEmpty {
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
                        ForEach(widgetAthletes.indices, id: \.self) { index in
                            let athlete = widgetAthletes[index]
                            
                            if (index % 2) == 0 && index != 0 {
                                BannerAd(style: .mediumRectangle)
                                    .frame(height: 250)
                            }
                            
                            NavigationLink {
                                BioView(athleteId: athlete.athleteId)
                            } label: {
                                AthleteCellView(athlete: athlete)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                BannerAd(style: .mediumRectangle)
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
        .onAppear {
            if search.text.isEmpty && !initialSearchText.isEmpty {
                search.text = initialSearchText
            }
        }
        .onChange(of: search.text) { _, newValue in
            Task {
                await searchModel.getSearchResults(from: newValue)
            }
        }
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
            
            ForEach(sortedSuggestions, id: \.id) { suggestion in
                Button {
                    setAthlete(from: suggestion)
                } label: {
                    HStack {
                        Text(suggestion.term)
                            .font(.appBodyStrong)
                            .foregroundColor(.appPrimary)
                            .lineSpacing(2)
                        Spacer()
                        Image(systemName: "plus.circle")
                            .foregroundColor(.appSecondary)
                    }
                    .padding(.vertical, AppSpace.xs)
                }
                .buttonStyle(.plain)

                if suggestion.id != sortedSuggestions.last?.id {
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

    private func setAthlete(from result: SearchResultElement) {
        Task {
            let bioApi = BioViewModel()
            await bioApi.getBio(for: result.id)
            let bio = bioApi.bio

            let alreadyExists = widgetAthletes.contains { $0.athleteId == bio.contestantId }
            guard !alreadyExists else {
                searchFieldFocused = false
                search.text = ""
                return
            }

            let athlete = WidgetAthlete(
                athleteId: bio.contestantId,
                name: bio.name,
                event: bio.topEvent.withTeamRopingConversion,
                events: bio.events
            )

            withAnimation {
                modelContext.insert(athlete)
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
                FavoriteAlert.added(athlete.name).present
                searchFieldFocused = false
                search.text = ""
            }
        }
    }
}

#Preview {
    AthletesView()
}
