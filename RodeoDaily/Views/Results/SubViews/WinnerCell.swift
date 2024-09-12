//
//  WinnerCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftUI

struct WinnerCell: View {

    let event: String
    let winner: Winner
    
    @State private var isShowingBio = false

    var body: some View {
        VStack {
            HStack {
                Text(winner.placeDisplay)
                    .font(.headline)
                    .foregroundColor(.appSecondary)
   
                winner.image
                    .overlay(Color.appTertiary.opacity(0.96)).mask(winner.image)
                
                VStack(alignment: .leading) {
                    NavigationLink {
                        BioView(athleteId: winner.contestantId, event: StandingsEvent(rawValue: event) ?? .bb)
                    } label: {
                        Text(winner.name)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.appPrimary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.borderless)
                    
                    Text(winner.hometownDisplay)
                        .font(.caption)
                        .foregroundColor(.appTertiary)
                }
                
                Spacer()
                
                HStack {
                    
                    
                    Spacer()
                    Text(winner.result)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    
                    Text(winner.earnings)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 90, alignment: .trailing)
                }
                .frame(width: 150)
            }
            
//            if isShowingBio {
//                BioCellView(athleteId: winner.contestantId, event: StandingsEvent(rawValue: event) ?? .aa, isShowingBio: isShowingBio)
//            }
        }
    }
}

struct WinnerCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
