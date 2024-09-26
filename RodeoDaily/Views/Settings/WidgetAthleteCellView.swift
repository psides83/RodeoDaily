//
//  SwiftUIView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/14/24.
//

import SwiftUI

struct WidgetAthleteCellView: View {
    @Bindable var athlete: WidgetAthlete
        
    let onChange: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(athlete.name)
                
                Text(athlete.event.eventDisplay)
                    .font(.caption)
            }
            
            Spacer()
        }
        .contextMenu {
            Picker("", selection: $athlete.event) {
                ForEach(athlete.events, id: \.self) { event in
                    Text(event.eventDisplay)
                        .tag(event)
                }
            }
        }
        .onChange(of: athlete.event) { onChange() }
    }
}

