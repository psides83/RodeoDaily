//
//  WinnerCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftUI

struct TRWinnerCell: View {

    let team: Team
    var widgetAthletes: [WidgetAthlete]
    
    @State private var isShowingBio = false
    @State private var isShowingPartnerBio = false

    var body: some View {
        VStack {
            HStack {
                
                Text(team.place)
                    .font(.title3)
                    .foregroundColor(.appSecondary)
                
                VStack(alignment: .leading) {
                    HStack {
                        team.headerImage
                            .overlay(Color.appTertiary.opacity(0.96)).mask(team.headerImage)
                        
                        VStack(alignment: .leading) {
                            Text("Header")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            NavigationLink {
                                BioView(athleteId: team.headerId)
//                                withAnimation {
//                                    isShowingBio.toggle()
//                                    isShowingPartnerBio = false
//                                }
                            } label: {
                                HStack {
                                    Text(team.headerName)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(isShowingBio ? .appSecondary : .appPrimary)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                                                        
                                    favoriteIcon(winnerId: team.headerId)
                                }
                            }
                            .buttonStyle(.borderless)
                            
                            Text(team.headerHometown)
                                .font(.caption)
                                .foregroundColor(.appTertiary)
                            
                        }
                    }
                    
                    HStack {
                        team.heelerImage
                            .overlay(Color.appTertiary.opacity(0.96)).mask(team.heelerImage)
                        
                        VStack(alignment: .leading) {
                            Text("Heeler")
                                .font(.caption)
                                .foregroundColor(.appTertiary)
                            
                            NavigationLink {
                                BioView(athleteId: team.heelerId)
//                                withAnimation {
//                                    isShowingBio = false
//                                    isShowingPartnerBio.toggle()
//                                }
                            } label: {
                                HStack {
                                    Text(team.heelerName)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(isShowingPartnerBio ? .appSecondary : .appPrimary)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    favoriteIcon(winnerId: team.heelerId)
                                }
                            }
                            .buttonStyle(.borderless)
                            
                            Text(team.heelerHometown)
                                .font(.caption)
                                .foregroundColor(.appTertiary)
                            
                        }
                    }
                }
                
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Text(team.time)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(team.payoff)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 90, alignment: .trailing)
                }
                .frame(width: 150)
            }
            
//            if isShowingBio {
//                BioCellView(athleteId: team.headerId, event: .hd, isShowingBio: isShowingBio)
//            }
//            
//            if isShowingPartnerBio {
//                BioCellView(athleteId: team.heelerId, event: .hl, isShowingBio: isShowingPartnerBio)
//            }
        }
    }
    
    func isFavorite(for winnerId: Int) -> Bool {
        if widgetAthletes.contains(where: { $0.athleteId == winnerId }) {
            return true
        }
        
        return false
    }
    
    @ViewBuilder
    func favoriteIcon(winnerId: Int) -> some View {
        switch isFavorite(for: winnerId) {
        case true:
            Image(systemName: "star.fill")
                .foregroundColor(.appSecondary)
        case false:
            EmptyView()
        }
    }
}
