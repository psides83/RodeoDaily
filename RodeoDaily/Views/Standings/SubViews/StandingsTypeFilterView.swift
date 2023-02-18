//
//  StandingsTypeFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct StandingsTypeFilterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: (_ type: StandingType) -> Void
    
    init(_ action: @escaping (_ type: StandingType) -> Void) { self.action = action }
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent) {
            FilterMenuIcon(label: NSLocalizedString("Type", comment: ""))
        }
        .menuStyle(.button)
    }
    
    // MARK: - View Methods
    func menuContent() -> some View {
        ForEach(StandingType.allCases, id: \.self) { type in
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
