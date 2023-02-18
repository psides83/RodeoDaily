//
//  StandingsEventFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct StandingsEventFilterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: (_ event: StandingsEvent) -> Void
    
    init(_ action: @escaping (_ event: StandingsEvent) -> Void) { self.action = action }
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent) {
            FilterMenuIcon(label: NSLocalizedString("Event", comment: ""))
        }
        .menuStyle(.button)
    }
    
    // MARK: - View Methods
    func menuContent() -> some View {
        ForEach(StandingsEvent.allCases, id: \.self) { event in
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
