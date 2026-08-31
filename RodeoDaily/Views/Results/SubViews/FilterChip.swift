//
//  DateFilterChip.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/13/22.
//

import SwiftUI

struct FilterChip: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let dateRangeDisplay: String
    
    @Binding var dateRange: Set<DateComponents>

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Filtered By:")
                    .foregroundColor(.appTertiary)
                    .font(.callout)
        
                HStack {
                    Text(dateRangeDisplay.replacingOccurrences(of: "Current Range: ", with: ""))
                        .font(.callout)
                    
                    Button {
                        withAnimation {
                            dateRange.removeAll()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.clearButtonSmall)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(chipBackground)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.appSecondary.opacity(colorScheme == .dark ? 0.35 : 0.22), lineWidth: 1)
                )
                .foregroundColor(chipForeground)
            }
            Spacer()
        }
    }

    private var chipBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.10) : Color.appSecondary.opacity(0.12)
    }

    private var chipForeground: Color {
        colorScheme == .dark ? .white : .appPrimary
    }
}
