//
//  AthletesView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/24/24.
//

import SwiftData
import SwiftUI

struct AthletesView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var widgetAthletes: [WidgetAthlete]

    var body: some View {
        ScrollView {
            Text("Favorite Athletes")
                .foregroundColor(.appSecondary)
                .font(.title)
                .fontWeight(.bold)
                .hSpacing(.leading)
            
            if widgetAthletes.isEmpty {
                ContentUnavailableView {
                    VStack {
                        Text("No Athletes")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPrimary)
                        
                        Image.cowboy
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 72, height:  72)
                            .foregroundStyle(Color.appPrimary)
                        
                    }
                } description: {
                    Text("Add athletes to favorites fromt he settings tab. These athletes will be available to add widgets to you home screen.")
                }
            } else {
                ForEach(widgetAthletes.indices, id: \.self) { index in
                    let athlete = widgetAthletes[index]
                    
                    if (index % 2) == 0 && index != 0 {
                        VStack {
                            BannerAd()
                                .frame(height: 350)
                        }
                    }
                    
                    NavigationLink {
                        BioView(athleteId: athlete.athleteId)
                    } label: {
                        AthleteCellView(athlete: athlete)
                            .padding(.bottom, 10)
                    }
                }
            }
            
            BannerAd()
                .frame(height: 400)
        }
    }
}

#Preview {
    AthletesView()
}
