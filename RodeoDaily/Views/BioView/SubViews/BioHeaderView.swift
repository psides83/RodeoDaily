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
    let athleteId: Int
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: AppSpace.md) {
            VStack(alignment: .leading, spacing: AppSpace.md) {
                HStack(alignment: .center, spacing: AppSpace.md) {
                    VStack(alignment: .leading, spacing: AppSpace.xxs) {
                        Text(viewModel.seasonRanking())
                            .font(.appBodyStrong)
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                            .lineLimit(2)
                        
                        Text(viewModel.bio.careerEarnings)
                            .foregroundColor(.appSecondary)
                            .font(.appBodyStrong)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: AppSpace.sm) {
                        actionButton(systemImage: favoriteIcon, label: "Favorite Athlete") {
                            handleFavorite()
                        }
                    }
                }
                
                HStack(spacing: AppSpace.sm) {
                    statPill(viewModel.bio.nfrQuals)
                    statPill(viewModel.bio.worldTitlesCount)
                    statPill(viewModel.bio.athleteAge + NSLocalizedString(" Years old", comment: ""))
                }
            }
//            .padding(.top, AppSpace.sm)
            
            Picker("", selection: $viewModel.infoType) {
                ForEach(BioViewModel.BioInfoType.allCases, id: \.self) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(AppSpace.xs)
        }
        .environment(\.colorScheme, .dark)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .padding(.horizontal)
        .background(Color.rdGreen)
    }
    
    @ViewBuilder
    private func actionButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundColor(.appSecondary)
                .font(.title3.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.appBg.opacity(0.2))
                )
                .overlay(
                    Circle()
                        .stroke(Color.appTertiary.opacity(0.35), lineWidth: AppStroke.hairline)
                )
        }
        .accessibilityLabel(label)
    }
    
    @ViewBuilder
    private func statPill(_ text: String) -> some View {
        Text(text)
            .font(.appCaptionStrong)
            .foregroundColor(.appPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpace.sm)
            .padding(.horizontal, AppSpace.xs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(Color.appBg.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.35), lineWidth: AppStroke.hairline)
            )
    }
    
    func handleFavorite() {
        if let athlete = widgetAthletes.first(where: { $0.athleteId == resolvedAthleteId }) {
            modelContext.delete(athlete)
            
            FavoriteAlert
                .removed(athlete.name)
                .present
        } else {
            let favorite = WidgetAthlete()
            favorite.athleteId = resolvedAthleteId
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
        if widgetAthletes.contains(where: { $0.athleteId == resolvedAthleteId }) {
            return true
        }
        
        return false
    }
    
    var resolvedAthleteId: Int {
        viewModel.bio.contestantId != 0 ? viewModel.bio.contestantId : athleteId
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
