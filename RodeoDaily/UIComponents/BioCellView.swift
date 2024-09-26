//
//  BioCellView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import SwiftUI
import WidgetKit

struct BioCellView: View {
    
    let athleteId: Int
    let event: StandingsEvent
    let isShowingBio: Bool
    
    @ObservedObject var bioAPI = BioViewModel()
    
    @AppStorage("favoriteAthlete", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthlete: FavoriteAthlete? = nil
    
    var isFavorite: Bool {
        guard let favorite = favoriteAthlete else { return false }
        
        guard favorite.id == athleteId && favorite.event == event else { return false }

        return true
    }
    
    var body: some View {
        let bio = bioAPI.bio
        let loading = bioAPI.loading
        
        VStack {
            if loading {
                BioViewLoader(loading: loading)
            } else {
                VStack(alignment: .center, spacing: 4) {
                    HStack {
                        Text(bio.careerEarnings)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .redacted(reason: loading ? .placeholder : .privacy)
                        
                        Spacer()
                        
                        if event.hasBio {
                            Button {
                                if isFavorite {
                                    deleteFavorite()
                                } else {
                                    setFavorite()
                                }
                            } label: {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundColor(.appSecondary)
                            }
                            .buttonStyle(.clearButton)
                        }
                    }
                    
                    
                    Divider()
                        .frame(minHeight: 2, alignment: .center)
                        .overlay(Color.appTertiary)
                    
                    HStack {
                        Text(bio.nfrQuals)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .redacted(reason: loading ? .placeholder : .privacy)
                        
                        Spacer()
                        
                        Divider()
                            .frame(width: 2, height: 14, alignment: .center)
                            .overlay(Color.appSecondary)
                        
                        Spacer()
                        
                        Text(bio.worldTitlesCount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .redacted(reason: loading ? .placeholder : .privacy)
                        
                        Spacer()
                        
                        Divider()
                            .frame(width: 2, height: 14, alignment: .center)
                            .overlay(Color.appSecondary)
                        
                        Spacer()
                        
                        Text(bio.athleteAge + NSLocalizedString(" Years old", comment: ""))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .redacted(reason: loading ? .placeholder : .privacy)
                    }
                }
                .frame(width: 300)
            }
        }
        .onChange(of: favoriteAthlete) {
            Task {
                await bioAPI.getBio(for: athleteId)
            }
        }
        .task {
            if isShowingBio {
                await bioAPI.getBio(for: athleteId)
            }
        }
    }
    
    func setFavorite() {
        withAnimation {
            let favorite = FavoriteAthlete(id: athleteId, name: bioAPI.bio.name, event: event, teamRopingEvent: bioAPI.bio.teamRopingEvent, events: bioAPI.bio.events)
            
            print(favorite)
            
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

struct BioCellView_Previews: PreviewProvider {
    static var previews: some View {
        BioCellView(athleteId: 70406, event: .td, isShowingBio: true)
    }
}
