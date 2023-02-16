//
//  FilterMenuIcon.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/15/23.
//

import SwiftUI

struct FilterMenuIcon: View {
    @Environment(\.colorScheme) var colorScheme
    
    let label: String
    
    var body: some View {
        VStack {
            Image.filter
                .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                .imageScale(.large)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.appSecondary)
        }
    }
}

struct FilterMenuIcon_Previews: PreviewProvider {
    static var previews: some View {
        FilterMenuIcon(label: "Type")
    }
}
