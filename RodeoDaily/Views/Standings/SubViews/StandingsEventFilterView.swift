//
//  StandingsEventFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct StandingsEventFilterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: (_ event: StandingsEvents) -> Void
    
    init(_ action: @escaping (_ event: StandingsEvents) -> Void) { self.action = action }
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent) {
            FilterMenuIcon(label: "Event")
        }
        .menuStyle(.button)
    }
    
    // MARK: - View Methods
    func menuContent() -> some View {
        ForEach(StandingsEvents.allCases, id: \.self) { event in
            Button {
                withAnimation {
                    action(event)
                }
            } label: {
                Text(event.title)
            }
        }
    }
}
