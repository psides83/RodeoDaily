//
//  CareerListView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

// TODO: Update to filter by event

struct CareerListView: View {
    
    let careerSeasons: [CareerWithEarinings]
    
    // MARK: - Body
    var body: some View {
        List {
            Section(header:
                        HStack{
                Text("Season")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Ranking")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Earnings")
                    .font(.headline)
                    .fontWeight(.bold)
            },
                    footer: BannerAd().frame(height: 300)
            ) {
                
                ForEach(careerSeasons, id: \.season) { season in
                    HStack {
                        Text(season.season)
                        
                        Spacer()
                        
                        Text(season.rank)
                        
                        Spacer()
                        
                        Text(season.earnings)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .listRowBackground(Color.appBg)
                }
            }
        }
        .listStyle(.plain)
    }
}
