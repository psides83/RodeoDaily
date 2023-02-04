//
//  StandingsList.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import SwiftUI

struct StandingsList: View {
    
    @Environment(\.colorScheme) var colorScheme
        
    let standings: [Position]
    var loading: Bool
    let selectedTab: Tabs
    let searchText: String
    
    @Binding var selectedYear: Int
    @Binding var selectedEvent: StandingsEvents
    
//    @State private var selectedEvent: StandingsEvents = .aa
    
    let adPlacement: Int = 10
    
    // MARK: - Body
    var body: some View {
        let filteredStandings = standings.filter({ searchText.isEmpty ? true : selectedTab == .standings && $0.name.localizedCaseInsensitiveContains(searchText) })
        
            HStack {
                VStack(alignment: .leading) {
                    Text(selectedYear.string)
                        .foregroundColor(.rdGray)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(selectedEvent.title)
                        .foregroundColor(.rdGreen)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("World Stadings")
                        .foregroundColor(.rdGray)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Spacer()
                    
                    Menu {
                        ForEach(StandingsEvents.allCases, id: \.self) { event in
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
                            .foregroundColor(colorScheme == .light ? .rdGreen : .primary)
                            .imageScale(.large)
                    }
                    .menuStyle(.button)
                    
                    Menu {
                        ForEach(years, id: \.self) { year in
                            Button {
                                withAnimation {
                                    selectedYear = year
                                }
                            } label: {
                                Text(year.string)
                            }
                        }
                        
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(colorScheme == .light ? .rdGreen : .primary)
                            .imageScale(.large)
                    }
            }
        
        if loading {
            StandingsLoader()
        } else if filteredStandings.count > 0 {
            ForEach(filteredStandings.indices, id: \.self) { index in
                if (index % adPlacement) == 0 && index != 0 {
                    VStack {
                        BannerAd()
                            .frame(height: 50)
                        
                        Divider()
                    }
                }
                StandingsCell(position: filteredStandings[index])
                
                Divider()
            }
        } else {
            Text("No Standings Found")
                .foregroundColor(.rdGreen)
                .font(.system(.largeTitle, weight: .semibold))
        }
    }
    
    // MARK: - Computed Properties
    var years: [Int] {
        var lastYear: Int {
            if Date().monthInt >= 10 {
                return Date().yearInt + 2
            } else {
                return Date().yearInt + 1
            }
        }
        
        var array: [Int] = []
        
        for year in 2017..<lastYear {
            array.append(year)
        }
        
        return array
    }
}

struct StandingsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
