//
//  WinnerCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftUI

struct TRWinnerCell: View {

    let winner: Winner
    let partner: Winner
    
    @State private var isShowingBio = false
    @State private var isShowingPartnerBio = false

    var body: some View {
        VStack {
            HStack {
                
                Text(winner.place.string)
                    .font(.title3)
                    .foregroundColor(.appSecondary)
                
                VStack(alignment: .leading) {
                    HStack {
                        winner.image
                            .overlay(Color.appTertiary.opacity(0.96)).mask(winner.image)
                        
                        VStack(alignment: .leading) {
                            Text("Header")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button {
                                withAnimation {
                                    isShowingBio.toggle()
                                    isShowingPartnerBio = false
                                }
                            } label: {
                                Text(winner.name)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(isShowingBio ? .appSecondary : .appPrimary)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderless)
                            
                            Text(winner.hometownDisplay)
                                .font(.caption)
                                .foregroundColor(.appTertiary)
                            
                        }
                    }
                    
                    HStack {
                        partner.image
                            .overlay(Color.appTertiary.opacity(0.96)).mask(partner.image)
                        
                        VStack(alignment: .leading) {
                            Text("Heeler")
                                .font(.caption)
                                .foregroundColor(.appTertiary)
                            
                            Button {
                                withAnimation {
                                    isShowingBio = false
                                    isShowingPartnerBio.toggle()
                                }
                            } label: {
                                Text(partner.name)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(isShowingPartnerBio ? .appSecondary : .appPrimary)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderless)
                            
                            Text(partner.hometownDisplay)
                                .font(.caption)
                                .foregroundColor(.appTertiary)
                            
                        }
                    }
                }
                
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    Text(winner.result)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    
                    Text(winner.payoff == 0 ? "" : winner.payoff.currency)
                        .font(.headline)
                }
                .frame(width: 150)
            }
            
            if isShowingBio {
                BioCellView(athleteId: winner.contestantId, event: .hd, isShowingBio: isShowingBio)
            }
            
            if isShowingPartnerBio {
                BioCellView(athleteId: partner.contestantId, event: .hl, isShowingBio: isShowingPartnerBio)
            }
        }
    }
}
