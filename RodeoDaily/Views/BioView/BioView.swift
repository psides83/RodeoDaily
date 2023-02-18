//
//  BioView.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/10/23.
//

import SwiftUI
import WidgetKit

struct BioView: View {
    //MARK: - Properties
    @Environment(\.calendar) var calendar
    
    enum BioInfoType: String {
        case bio = "Bio"
        case results = "Results"
        case career = "Career"
    }
    
    let athleteId: Int
    let event: StandingsEvent
    
    @ObservedObject var bioApi = BioApi()
    
    @AppStorage("favoriteAthlete", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthlete: FavoriteAthlete? = nil
    
    // MARK: - State Properties
    @State private var infoType: BioInfoType = .results
    @State private var showSearchBar = false
    
    // MARK: - View Body
    var body: some View {
        Group {
            if bioApi.loading {
                LogoLoader()
                    .offset(y: 150)
            } else {
                VStack(spacing: 0) {
                    if !showSearchBar {
                        BioHeadingView(event: event, bio: bioApi.bio, infoType: $infoType)
                        .scaleEffect(x: 1, y: showSearchBar ? 0 : 1, anchor: .top)
                        .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                    }
                    
                    if infoType == .bio {
                        HtmlView(htmlContent: bioApi.bio.biographyText)
                        BannerAd()
                            .frame(height: 50)
                    }
                    
                    if infoType == .results {
                        ResultsListView(bio: bioApi.bio,
                                        event: eventWithTrConversion,
                                        seasons: seasons,
                                        showSearchBar: $showSearchBar
                        )
                    }
                    
                    if infoType == .career {
                        CareerListView(careerSeasons: bioApi.bio.careerSeasons(filteredBy: event))
                    }
                }
                .background(Color.appBg)
                .navigationTitle(event.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color.rdGreen, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarRole(.navigationStack)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { favoriteButton() }
                }
            }
        }
        .task {
            if athleteId != 0 {
                await bioApi.getBio(for: athleteId)
            }
        }
    }
    
    // MARK: - View Methods
    func favoriteButton() -> some View {
        Group {
            if event.hasBio {
                Button(action: toggleFavorite, label: favoriteIcon)
                    .buttonStyle(.clearButton)
            } else {
                EmptyView()
            }
        }
    }
    
    func favoriteIcon() -> some View {
        Image(systemName: isFavoriteAthlete ? "star.fill" : "star")
            .foregroundColor(.appSecondary)
    }
    
    //MARK: - Computed Properties
    var eventWithTrConversion: String {
        guard event == .hd || event == .hl else { return event.rawValue }
        return "TR"
    }
    
    var isFavoriteAthlete: Bool {
        guard let favorite = favoriteAthlete else { return false }
        guard favorite.id == athleteId && favorite.event.rawValue == event.rawValue else { return false }
        return true
    }
    
    var currentYearEarnings: String {
        return bioApi
            .bio
            .career
            .filter({
                $0.season == Date().yearInt
                &&
                $0.eventType == eventWithTrConversion
                
            })[0]
            .earnings
            .currencyABS
    }
    
    var seasons: [String] {
        return bioApi
            .bio
            .career
            .filter({ $0.eventType == eventWithTrConversion })
            .map({ $0.season.string })
            .sorted(by: { $0 > $1 })
    }
    
    // MARK: - Methods
    func toggleFavorite() {
        if isFavoriteAthlete {
            deleteFavorite()
        } else {
            setFavorite()
        }
    }
    
    func setFavorite() {
        withAnimation {
            let favorite = FavoriteAthlete(id: athleteId, name: bioApi.bio.name, event: event)
            
            favoriteAthlete = favorite
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func deleteFavorite() {
        withAnimation {
            guard let favorite = favoriteAthlete else { return }
            
            guard favorite.id == athleteId else { return }
            
            favoriteAthlete = nil
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

// MARK: - Preview
struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BioView(athleteId: 59836, event: .hd)
                .tint(.appSecondary)
        }
    }
}
