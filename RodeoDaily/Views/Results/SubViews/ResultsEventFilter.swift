//
//  ResultsEventFilter.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct ResultsEventFilter: View {
    @Environment(\.colorScheme) var colorScheme

    let action: (_ event: Events.CodingKeys) -> Void
    
    var body: some View {
        Menu {
            ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                Button {
                    withAnimation {
                        action(event)
                    }
                } label: {
                    Text(event.title)
                }
            }
            
        } label: {
            VStack {
                Image.filter
                    .imageScale(.large)
                    .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                
                Text("Event")
                    .font(.caption)
                    .foregroundColor(.appSecondary)
            }
        }
    }
}
