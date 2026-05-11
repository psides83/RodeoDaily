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
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(athlete.name)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
                
                Text("Widget Event")
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
            }
            
            Spacer()
            
            Text(athlete.event.eventDisplay)
                .font(.appCaptionStrong)
                .foregroundColor(.appPrimary)
                .padding(.horizontal, AppSpace.sm)
                .padding(.vertical, AppSpace.xxs)
                .background(
                    Capsule()
                        .fill(Color.appSecondary.opacity(0.18))
                )
            
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.appTertiary)
        }
        .padding(.vertical, AppSpace.xs)
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
