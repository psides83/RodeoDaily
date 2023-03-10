//
//  DateFilterChip.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/13/22.
//

import SwiftUI

struct FilterChip: View {
    
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
                .background(Color.appPrimary)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            Spacer()
        }
    }
}
