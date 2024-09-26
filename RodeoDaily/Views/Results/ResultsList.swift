//
//  ResultsList.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct ResultsList: View {        
    @Environment(\.colorScheme) var colorScheme
    
    let rodeos: [RodeoData]
    let loading: Bool
    var widgetAthletes: [WidgetAthlete]
    
    @Binding var selectedEvent: Events.CodingKeys
    @Binding var index: Int
    @Binding var dateRange: Set<DateComponents>
    @State var popover: PopoverModel?
    
    @State var dateRangeDisplay = ""
    @State var isShowingCalendar = false
    
    let adPlacement: Int = 5
    let helpMessage: LocalizedStringKey = "For rodeos like **RODEOHOUSTON** where rounds are broken up into ***brackets***, all the braket's winners are lumped into the given round in the results. You might see multiple athletes who placed 1st and won the same money but all with different times/scores in a given round. This is due to the ***bracket format***."
    
    //MARK: - Body
    var body: some View {
        let filteredRodeos = rodeos.sorted(by: { $0.endDate > $1.endDate })
        
        VStack(alignment: .center, spacing: 16) {
            listHeader
            
            if dateRange.count > 1 {
                FilterChip(dateRangeDisplay: dateRangeDisplay, dateRange: $dateRange)
            }
            
            if rodeos.count > 0 {
                ForEach(filteredRodeos.indices, id: \.self) { index in
                    if (index % adPlacement) == 0 && index != 0 {
                        VStack {
                            BannerAd()
                                .frame(minHeight: 100)
                            
                            Divider()
                                .overlay(Color.appTertiary)
                        }
                    }
                    
                    RodeoCell(rodeo: filteredRodeos[index], event: selectedEvent, widgetAthletes: widgetAthletes)
                    
                    Divider()
                        .overlay(Color.appTertiary)
                }
            } else if rodeos.count == 0 && !loading {
                Text("No Results Found")
                    .foregroundColor(.appPrimary)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else if loading {
                RodeosLoader()
            }
            
            LoadMoreButton(loading: loading, action: incrementIndex)
            
            BannerAd()
                .frame(height: 300)
        }
        .padding(.bottom)
        .onChange(of: isShowingCalendar) { old, newValue in
            if newValue == false && dateRange.count < 2 {
                dateRange.removeAll()
            }
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker(dateRange: $dateRange, dateRangeDisplay: $dateRangeDisplay, isShowingCalendar: $isShowingCalendar)
        }
    }
    
    // MARK: - Sub Views
    var listHeader: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 22) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(selectedEvent.title)
                        .foregroundColor(.appPrimary)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Rodeo Results")
                            .foregroundColor(.appSecondary)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Button {
                            popover = PopoverModel(message: "help")
                        } label: {
                            Image.help
                                .foregroundColor(.appPrimary)
                        }
                        .buttonStyle(.clearButton)
                        .sheet(item: $popover) { _ in
                            VStack {
                                Text("**Important**")
                                    .font(.largeTitle)
                                
                                Text(helpMessage)
                                    .font(.title3)
                                    .padding()
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.rdGreen.edgesIgnoringSafeArea(.all))
                            .presentationDetents([.height(340)])
                            .presentationDragIndicator(.visible)
                            .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                ResultsEventFilter { event in
                    selectedEvent = event
                }
                
                Button(action: showCalendar, label: calendarButton)
                    .buttonStyle(.clearButton)
            }
        }
    }
    
    //MARK: - View Methods
    func calendarButton() -> some View {
        VStack {
            Image.calendar
                .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                .imageScale(.large)
            
            Text("Dates")
                .font(.caption)
                .foregroundColor(.appSecondary)
        }
    }
    
    // MARK: - Methods
    func showCalendar() {
        isShowingCalendar = true
    }
    
    func incrementIndex() {
        index += 1
    }
}

struct ResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PopoverModel: Identifiable {
    var id: String { message }
    let message: String
}
