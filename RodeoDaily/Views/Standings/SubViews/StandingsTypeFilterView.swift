//
//  StandingsTypeFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct StandingsTypeFilterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: (_ type: StandingTypes) -> Void
    
    init(_ action: @escaping (_ type: StandingTypes) -> Void) { self.action = action }
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent) {
            FilterMenuIcon(label: "Type")
        }
        .menuStyle(.button)
    }
    
    // MARK: - View Methods
    func menuContent() -> some View {
        ForEach(StandingTypes.allCases, id: \.self) { type in
            Button {
                withAnimation {
                    action(type)
                }
            } label: {
                Text(type.title)
            }
        }
    }
}
