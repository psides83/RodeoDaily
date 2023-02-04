//
//  ResultsList.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct ResultsList: View {
        
    @Environment(\.calendar) var calendar
    @Environment(\.colorScheme) var colorScheme
    
    let rodeos: [RodeoData]
    let dateParams: String
    
    var loading: Bool
    
    @Binding var selectedEvent: Events.CodingKeys
    @Binding var index: Int
    @Binding var dateRange: Set<DateComponents>
    
    @State private var isShowingCalendar = false
    
    let adPlacement: Int = 5
    
    //MARK: - Body
    var body: some View {
        let filteredRodeos = rodeos.sorted(by: { $0.endDate > $1.endDate })
        
        VStack(alignment: .center, spacing: 16) {
            
            ListHeader
            
            if dateRange.count > 1 {
                FilterChip(dateRangeDisplay: dateRangeDisplay, dateRange: $dateRange)
            }
            
            if rodeos.count > 0 {
                ForEach(filteredRodeos.indices, id: \.self) { index in
                    if (index % adPlacement) == 0 && index != 0 {
                        VStack {
                            BannerAd()
                                .frame(minHeight: 80)
                            
                            Divider()
                        }
                    }
                    
                    RodeoCell(rodeo: filteredRodeos[index], event: selectedEvent)
                    
                    Divider()
                }
            } else if rodeos.count == 0 && !loading {
                Text("No Results Found")
                    .foregroundColor(.rdGreen)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else if loading {
                RodeosLoader()
            }
            
            LoadMoreButton(loading: loading, action: incrementIndex)
        }
        .padding(.bottom)
        .onChange(of: isShowingCalendar) { newValue in
            if newValue == false && dateRange.count < 2 {
                dateRange.removeAll()
            }
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker(dateRange: $dateRange, dateRangeDisplay: dateRangeDisplay)
        }
    }
    
    // MARK: - Sub Views
    var ListHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(selectedEvent.title)
                    .foregroundColor(.rdGreen)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Rodeo Results")
                    .foregroundColor(.rdGray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Menu {
                ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                    Button {
                        withAnimation {
                            selectedEvent = event
                        }
                    } label: {
                        Text(event.title)
                    }
                }
                
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.rdGreen)
            }
            
            Button {
                isShowingCalendar = true
            } label: {
                Image(systemName: "calendar")
                    .foregroundColor(colorScheme == .light ? .rdGreen : .primary)
                    .imageScale(.large)
            }
            .buttonStyle(.clearButton)
        }
    }
    
    // MARK: - Computed Properties
    var dateRangeDisplay: String {
        var range = dateRange.compactMap { components in
            calendar.date(from: components)
        }.sorted(by: { $0 < $1 })
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yy"
        
        if range.count > 1 {
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
        
        return "*Select two dates"
    }
    
    // MARK: - Methods
    func incrementIndex() {
        index += 1
    }
}

struct ResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
