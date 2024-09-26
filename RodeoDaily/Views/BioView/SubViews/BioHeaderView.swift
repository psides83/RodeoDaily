//
//  BioHeaderView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import AlertKit
import SwiftData
import SwiftUI

struct BioHeaderView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var widgetAthletes: [WidgetAthlete]

    @ObservedObject var viewModel: BioViewModel
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 6) {
            VStack(alignment: .center, spacing: 4) {
                Text(viewModel.seasonRanking())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appPrimary)
                    .hSpacing(.leading)
                
                HStack {
                    Text(viewModel.bio.careerEarnings)
                        .foregroundColor(.appSecondary)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 2)
                        .hSpacing(.leading)
                    
                    Spacer()
                    
                    Button {
                        handleFavorite()
                    } label: {
                        Image(systemName: favoriteIcon)
                            .foregroundColor(.appSecondary)
                            .font(.title2)
                    }
                }
                
                Divider()
                    .frame(minHeight: 2, alignment: .center)
                    .overlay(Color.appTertiary)
                
                HStack {
                    Text(viewModel.bio.nfrQuals)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 2, height: 14, alignment: .center)
                        .overlay(Color.appSecondary)
                    
                    Spacer()
                    
                    Text(viewModel.bio.worldTitlesCount)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 2, height: 14, alignment: .center)
                        .overlay(Color.appSecondary)
                    
                    Spacer()
                    
                    Text(viewModel.bio.athleteAge + NSLocalizedString(" Years old", comment: ""))
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
                    
            Picker("", selection: $viewModel.infoType) {
                        ForEach(BioViewModel.BioInfoType.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .hSpacing(.center)
        }
        .environment(\.colorScheme, .dark)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .padding(.horizontal)
        .background(Color.rdGreen)
    }
    
    func handleFavorite() {
        if let athlete = widgetAthletes.first(where: { $0.athleteId == viewModel.bio.contestantId }) {
            modelContext.delete(athlete)
            
            FavoriteAlert
                .removed(athlete.name)
                .present
        } else {
            let favorite = WidgetAthlete()
            favorite.athleteId = viewModel.bio.contestantId
            favorite.name = viewModel.bio.name
            favorite.event = viewModel.selectedEvent ?? viewModel.bio.topEvent.withTeamRopingConversion
            favorite.events = viewModel.bio.events
            
            modelContext.insert(favorite)
            
            FavoriteAlert
                .added(favorite.name)
                .present
        }
    }
    
    var favoriteIcon: String {
        switch isFavorite {
        case true: return "star.fill"
        case false: return "star"
        }
    }
    
    var isFavorite: Bool {
        if widgetAthletes.contains(where: { $0.athleteId == viewModel.bio.contestantId }) {
            return true
        }
        
        return false
    }
    
    func alert() {
        
    }
}

#Preview {
    NavigationView {
        BioView(athleteId: 72983)
            .tint(.appSecondary)
            .navigationBarTitleDisplayMode(.inline)
    }
}
