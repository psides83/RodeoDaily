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
                    .font(.headline)
                
                VStack(alignment: .leading) {
                    HStack {
                        winner.image
                            .overlay(Color.gray.opacity(0.96)).mask(winner.image)
                        
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
                                    .foregroundColor(isShowingBio ? .rdYellow : .rdGreen)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderless)
                            
                            Text(winner.hometown ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                        }
                    }
                    
                    HStack {
                        partner.image
                            .overlay(Color.gray.opacity(0.96)).mask(partner.image)
                        
                        VStack(alignment: .leading) {
                            Text("Heeler")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button {
                                withAnimation {
                                    isShowingBio = false
                                    isShowingPartnerBio.toggle()
                                }
                            } label: {
                                Text(partner.name)
                                    .foregroundColor(isShowingPartnerBio ? .rdYellow : .rdGreen)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderless)
                            
                            Text(partner.hometown ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                        }
                    }
                }
                
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    Text(winner.result)
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                    
                    Text(winner.payoff == 0 ? "" : winner.payoff.currency)
                        .font(.subheadline)
                }
                .frame(width: 150)
            }
            
            if isShowingBio {
                BioView(athleteId: winner.contestantId, isShowingBio: isShowingBio)
            }
            
            if isShowingPartnerBio {
                BioView(athleteId: partner.contestantId, isShowingBio: isShowingPartnerBio)
            }
        }
    }
}
