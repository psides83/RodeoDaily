//
//  DatePicker.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI

struct DatePicker: View {
    @Environment(\.calendar) var calendar
    
    var bounds: PartialRangeThrough<Date> {
        let end = Date.now
        return ...end
    }
    
    @Binding var dateRange: Set<DateComponents>
    @Binding var dateRangeDisplay: String
    @Binding var isShowingCalendar: Bool
    var allowsFutureDates = false
    
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate = Date.now
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    boundedDatePicker("Start", selection: $startDate)
                    boundedDatePicker("End", selection: $endDate)
                } footer: {
                    Text("Items that overlap this date range will be shown.")
                }

                if !dateRange.isEmpty {
                    Section {
                        Button(role: .destructive, action: removeDates) {
                            Label("Clear Date Filter", systemImage: "xmark.circle")
                        }
                    }
                }
            }
            .navigationTitle("Date Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingCalendar = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply", action: searchDates)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear(perform: receiveDateRange)
        .presentationDetents([.height(dateRange.isEmpty ? 260 : 330), .medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func boundedDatePicker(_ title: String, selection: Binding<Date>) -> some View {
        if allowsFutureDates {
            SwiftUI.DatePicker(title, selection: selection, displayedComponents: .date)
        } else {
            SwiftUI.DatePicker(title, selection: selection, in: bounds, displayedComponents: .date)
        }
    }

    // MARK: - Computed Properties
    var rangeDisplay: String {
        let range = [min(startDate, endDate), max(startDate, endDate)]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yy"

        return "Current Range: \(formatter.string(from: range[0])) - \(formatter.string(from: range[1]))"
    }
    
    // MARK: - Methods
    func receiveDateRange() {
        let existingRange = dateRange.compactMap { components in
            calendar.date(from: components)
        }.sorted(by: { $0 < $1 })

        guard existingRange.count == 2,
              let existingStart = existingRange.first,
              let existingEnd = existingRange.last else {
            return
        }

        startDate = existingStart
        endDate = existingEnd
    }
    
    func searchDates() {
        withAnimation {
            let orderedStart = min(startDate, endDate)
            let orderedEnd = max(startDate, endDate)
            dateRange = [
                calendar.dateComponents([.year, .month, .day], from: orderedStart),
                calendar.dateComponents([.year, .month, .day], from: orderedEnd)
            ]
            dateRangeDisplay = rangeDisplay
            isShowingCalendar = false
        }
    }
    
    func removeDates() {
        withAnimation {
            dateRange.removeAll()
            dateRangeDisplay = ""
            isShowingCalendar = false
        }
    }
}
