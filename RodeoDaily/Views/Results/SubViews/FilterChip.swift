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
                .foregroundColor(.appPrimary)
                .appGlassSurface(
                    Capsule(style: .continuous),
                    tint: Color.appBg,
                    strokeOpacity: 0.18,
                    shadowOpacity: 0.03
                )
            }
            Spacer()
        }
    }
}
