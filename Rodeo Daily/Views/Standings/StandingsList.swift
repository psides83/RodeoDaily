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
    @Binding var standingType: StandingTypes
    @Binding var circuit: Circuits
    
    //    @State private var selectedEvent: StandingsEvents = .aa
    
    let adPlacement: Int = 10
    
    // MARK: - Body
    var body: some View {
        let filteredStandings = standings.filter({ searchText.isEmpty ? true : selectedTab == .standings && $0.name.localizedCaseInsensitiveContains(searchText) })
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 22) {
                Text(selectedYear.string)
                    .foregroundColor(.appPrimary)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if standingType == .circuit {
                    Menu {
                        ForEach(Circuits.allCases, id: \.self) { cir in
                            Button {
                                withAnimation {
                                    circuit = cir
                                }
                            } label: {
                                Text(cir.title)
                            }
                        }
                        
                    } label: {
                        VStack {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                                .imageScale(.large)
                            
                            Text("Circuit")
                                .font(.caption)
                                .foregroundColor(.appSecondary)
                            
                        }
                        
                    }
                    .menuStyle(.button)
                }
                
                if standingType != .xBulls && standingType != .xBroncs && standingType != .legacySteerRoping {
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
                        VStack {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                                .imageScale(.large)
                            
                            Text("Event")
                                .font(.caption)
                                .foregroundColor(.appSecondary)
                        }
                    }
                    .menuStyle(.button)
                }
                
                Menu {
                    ForEach(StandingTypes.allCases, id: \.self) { type in
                        Button {
                            withAnimation {
                                standingType = type
                            }
                        } label: {
                            Text(type.title)
                        }
                    }
                    
                } label: {
                    VStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                            .imageScale(.large)
                        
                        Text("Type")
                            .font(.caption)
                            .foregroundColor(.appSecondary)
                        
                    }
                    
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
                    VStack {
                        Image(systemName: "calendar")
                            .foregroundColor(colorScheme == .light ? .appPrimary : .primary)
                            .imageScale(.large)
                        Text("Year")
                            .font(.caption)
                            .foregroundColor(.appSecondary)
                    }
                }
            }
            
            if standingType != .xBulls && standingType != .xBroncs && standingType != .legacySteerRoping {
                Text(selectedEvent.title)
                    .foregroundColor(.appPrimary)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            if standingType == .circuit {
                Text("\(circuit.title) \(standingType.title)")
                    .foregroundColor(.appSecondary)
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                
                Text(standingType.title)
                    .foregroundColor(.appSecondary)
                    .font(.title)
                    .fontWeight(.bold)
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
                            .overlay(Color.appTertiary)
                    }
                }
                StandingsCell(position: filteredStandings[index])
                
                Divider()
                    .overlay(Color.appTertiary)
            }
            
            BannerAd()
                .frame(height: 50)
        } else {
            Text("No Standings Found")
                .foregroundColor(.appPrimary)
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
        
        for year in 2009..<lastYear {
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
