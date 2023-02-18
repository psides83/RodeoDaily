//
//  DatePicker.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI

struct DatePicker: View {
    @Environment(\.calendar) var calendar
    
    var bounds: PartialRangeUpTo<Date> {
        let end = Date.now
        return ..<end
    }
    
    @Binding var dateRange: Set<DateComponents>
    @Binding var dateRangeDisplay: String
    @Binding var isShowingCalendar: Bool
    
    @State var selectedDateRange = Set<DateComponents>()
    @State var selectedDates = [SelectedDate]()
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Date Filter")
                    .foregroundColor(.appPrimary)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
//                    .frame(maxWidth: 360, alignment: .leading)
                
                Spacer()
                
                if selectedDateRange.count == 2 {
                    Button(action: searchDates, label: searchDatesButtonLabel)
                }
            }
            
            HStack {
                Text(rangeDisplay)
                    .font(.callout)
                    .frame(maxWidth: 360, alignment: .leading)
                
                Spacer()
                
                Button(action: removeDates, label: removeDatesButton)
                    .buttonStyle(.clearButton)
                    .padding(.trailing, 10)
                    .opacity(dateRange.count == 0 ? 0 : 1)
                    .disabled(dateRange.count == 0)
            }
            
            MultiDatePicker(selection: $selectedDateRange, in: bounds) {
                Label("Dates", systemImage: "calendar")
            }
            .tint(.appPrimary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke().foregroundColor(.appSecondary))
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
        }
        .onAppear(perform: receiveDateRange)
        .onChange(of: dateRange) { newValue in
//            let newDate = SelectedDate(id: dateRange.count, date: newValue)
//            handleDateRange(newDate: <#T##SelectedDate#>)
        }
        .frame(maxWidth: 360, maxHeight: 450)
        .padding(.vertical, 20)
    }
    
    // MARK: - View Methods
    func searchDatesButtonLabel() -> some View {
        Text("Search Dates")
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.appPrimary, lineWidth: 1)
            )
    }
    
    func removeDatesButton() -> some View {
        Image(systemName: "delete.left.fill")
            .imageScale(.large)
            .foregroundColor(.appTertiary)
    }
    
    // MARK: - Computed Properties
    var rangeDisplay: String {
        var range = selectedDateRange.compactMap { components in
            calendar.date(from: components)
        }.sorted(by: { $0 < $1 })
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yy"
        
        if range.count == 2 {
            guard let first = range.first else { return "" }
            guard let last = range.last else { return "" }
            
            range.forEach { date in
                let index = range.firstIndex(of: date)
                range.remove(at: index!)
            }
            
            let firstDate = formatter.string(from: first)
            
            
            let secondDate = formatter.string(from: last)
            
            return "Current Range: \(firstDate) - \(secondDate)"
        }
        
        if range.count == 1 {
            guard let first = range.first else { return "" }
            
            range.forEach { date in
                let index = range.firstIndex(of: date)
                range.remove(at: index!)
            }
            
            let firstDate = formatter.string(from: first)
            
            return "Current Range: \(firstDate) -"
        }
        
        if range.count > 2 {
            return "*Only select TWO dates to set a range"
        }
        
        return "*Select two dates"
    }
    
    // MARK: - Methods
    func passDateRange() {
        dateRange = selectedDateRange
    }
    
    func receiveDateRange() {
        selectedDateRange = dateRange
    }
    
    func searchDates() {
        withAnimation {
            dateRange = selectedDateRange
            dateRangeDisplay = rangeDisplay
            isShowingCalendar = false
        }
    }
    
    func removeDates() {
        withAnimation {
            dateRange.removeAll()
        }
    }
    
    func handleDateRange(newDate: SelectedDate) {
//        guard dateRange.count > 0 else { return }
//        let newRange = dateRange.filter({ dateRange.firstIndex(of: $0) == dateRange.startIndex || dateRange.firstIndex(of: $0) == dateRange.endIndex })
        
        print("new date range", dateRange)
    }
}

struct SelectedDate: Identifiable {
    let id: Int
    let date: DateComponents
}
