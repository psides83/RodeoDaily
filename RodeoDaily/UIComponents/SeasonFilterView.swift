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
        HStack(spacing: AppSpace.xs) {
            Image.calendar
                .imageScale(.medium)
                .foregroundColor(.appPrimary)
            
            Text(selectedSeason)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appSecondary)

            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(.appTertiary)
        }
        .padding(.horizontal, AppSpace.md)
        .padding(.vertical, AppSpace.sm)
        .background(
            Capsule(style: .continuous)
                .fill(Color.appBg)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
        )
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
