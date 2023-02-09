//
//  WinnerCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftUI

struct WinnerCell: View {

    let winner: Winner
    
    @State private var isShowingBio = false

    var body: some View {
        VStack {
            HStack {
                
                Text(winner.place.string)
                    .font(.headline)
                    .foregroundColor(.appSecondary)
                
                
                
                winner.image
                    .overlay(Color.appTertiary.opacity(0.96)).mask(winner.image)
                
                VStack(alignment: .leading) {
                    
                    Button {
                        withAnimation {
                             isShowingBio.toggle()
                        }
                    } label: {
                        Text(winner.name)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.appPrimary)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.borderless)
                    
                    Text(winner.hometown ?? "")
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
                    
                    Text(winner.payoff == 0 ? "" : winner.payoff.currency)
                        .font(.headline)
                }
                .frame(width: 150)
            }
            
            if isShowingBio {
                BioView(athleteId: winner.contestantId, isShowingBio: isShowingBio)
            }
        }
    }
}

struct WinnerCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
