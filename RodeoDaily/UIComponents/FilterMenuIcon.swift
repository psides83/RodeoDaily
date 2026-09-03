//
//  FilterMenuIcon.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/15/23.
//

import SwiftUI

struct FilterMenuIcon: View {
    let label: String
    
    var body: some View {
        VStack(spacing: AppSpace.xxs) {
            Image.filter
                .foregroundColor(.appPrimary)
                .imageScale(.large)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.appSecondary)
        }
        .frame(minWidth: 64)
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
}

struct FilterMenuIcon_Previews: PreviewProvider {
    static var previews: some View {
        FilterMenuIcon(label: "Type")
    }
}
