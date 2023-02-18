//
//  CircuitFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct CircuitFilterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: (_ circuit: Circuit) -> Void
    
    init(_ action: @escaping (_ circuit: Circuit) -> Void) { self.action = action }
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent) {
            FilterMenuIcon(label: NSLocalizedString("Circuit", comment: ""))
        }
        .menuStyle(.button)
    }
    
    // MARK: - View Methods
    func menuContent() -> some View {
        ForEach(Circuit.allCases, id: \.self) { circuit in
            Button {
                withAnimation {
                    action(circuit)
                }
            } label: {
                Text(circuit.title)
            }
        }
    }
}
