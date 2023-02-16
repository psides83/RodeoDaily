//
//  CircuitFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct CircuitFilterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: (_ circuit: Circuits) -> Void
    
    init(_ action: @escaping (_ circuit: Circuits) -> Void) { self.action = action }
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent) {
            FilterMenuIcon(label: "Circuit")
        }
        .menuStyle(.button)
    }
    
    // MARK: - View Methods
    func menuContent() -> some View {
        ForEach(Circuits.allCases, id: \.self) { circuit in
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
