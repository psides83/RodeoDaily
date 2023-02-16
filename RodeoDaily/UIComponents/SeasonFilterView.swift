//
//  SeasonFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct SeasonFilterView: View {
    
    let seasons: [String]
    @Binding var selectedSeason: String
        
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent, label: menuIcon)
    }
    
    func menuIcon() -> some View {
        VStack {
            Image.calendar
                .imageScale(.large)
                .foregroundColor(.appPrimary)
            
            Text(selectedSeason)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    func menuContent() -> some View {
        ForEach(seasons, id: \.self) { season in
            Button {
                selectedSeason = season
            } label: {
                Text(season)
            }
        }
    }
}
