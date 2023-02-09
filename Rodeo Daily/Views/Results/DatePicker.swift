//
//  DatePicker.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI

struct DatePicker: View {
    
    var bounds: PartialRangeUpTo<Date> {
        let end = Date.now
        return ..<end
    }
    
    @Binding var dateRange: Set<DateComponents>
    
    let dateRangeDisplay: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Date Filter")
                .foregroundColor(.appPrimary)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: 360, alignment: .leading)
            
            HStack {
                
                Text(dateRangeDisplay)
                    .font(.callout)
                    .frame(maxWidth: 360, alignment: .leading)
                
                Spacer()
                
                Button {
                    withAnimation {
                        dateRange.removeAll()
                    }
                } label: {
                    Image(systemName: "delete.left.fill")
                        .foregroundColor(.appTertiary)
                        .opacity(dateRange.count == 0 ? 0 : 1)
                        .disabled(dateRange.count == 0)
                }
                .buttonStyle(.clearButton)
                .padding(.trailing, 10)
            }
            
            MultiDatePicker(selection: $dateRange, in: bounds) {
                Label("Dates", systemImage: "calendar")
            }
            .tint(.appPrimary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke().foregroundColor(.appSecondary))
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
        }
        .frame(maxWidth: 360, maxHeight: 450)
        .padding(.vertical, 20)
    }
}
