//
//  StandingsList.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import SwiftUI

struct StandingsList: View {
    @Environment(\.colorScheme) var colorScheme

    var widgetAthletes: [WidgetAthlete]
    let standings: [Position]
    var loading: Bool
    let selectedTab: Tabs
    let searchText: String
    
    @Binding var selectedYear: String
    @Binding var selectedEvent: StandingsEvent
    @Binding var standingType: StandingType
    @Binding var selectedCircuit: Circuit
    
    let adPlacement: Int = 10
    
    // MARK: - Body
    var body: some View {
        listHeader
        
        if loading {
            StandingsLoader()
        } else if filteredStandings.count > 0 {
            standingsList
            
            BannerAd()
                .frame(height: 400)
        } else {
            noStandings
        }
    }
    
    // MARK: - Computed View Properties
    var standingsList: some View {
        ForEach(filteredStandings.indices, id: \.self) { index in
            let position = filteredStandings[index]
            
            if (index % adPlacement) == 0 && index != 0 {
                VStack {
                    BannerAd()
                        .frame(height: 100)
                    
                    Divider()
                        .overlay(Color.appTertiary)
                }
            }
            
            if position.hasBio {
                NavigationLink {
                    BioView(athleteId: position.id)
                } label: {
                    StandingsCell(position: position, widgetAthletes: widgetAthletes)
                }
            } else {
                StandingsCell(position: position, widgetAthletes: widgetAthletes)
            }
            
            Divider()
                .overlay(Color.appTertiary)
        }
    }
    
    var listHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 22) {
                Text(selectedYear)
                    .foregroundColor(.appPrimary)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if standingType == .circuit {
                    CircuitFilterView(setCircuit)
                }
                
                if standingType.hasEvents {
                    StandingsEventFilterView(setEvent)
                }
                
                StandingsTypeFilterView(setType)
                
                SeasonFilterView(seasons: years, selectedSeason: $selectedYear)
            }
            
            listTitle
        }
    }
    
    var listTitle: some View {
        Group {
            if standingType.isNotSingleEvent {
                Text(selectedEvent.title)
                    .foregroundColor(.appPrimary)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            if standingType == .circuit {
                Text("\(selectedCircuit.title) \(standingType.title)")
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
    }
    
    var noStandings: some View {
        ContentUnavailableView {
            Label("Standings Could Not Load", systemImage: "list.number")
                .foregroundColor(.appPrimary)
        } description: {
            Text("We were not able to load these standings at this time. Try again later")
                .foregroundColor(.appPrimary)
        }
    }
    
    // MARK: - Computed Properties
    var filteredStandings: [Position] {
        standings.filter({
            searchText.isEmpty ? true : selectedTab == .standings
            &&
            $0.name.localizedCaseInsensitiveContains(searchText)
        })
    }
    
    var years: [String] {
        var lastYear: Int {
            if Date().monthInt >= 10 {
                return Date().yearInt + 2
            } else {
                return Date().yearInt + 1
            }
        }
        
        var array: [String] = []
        
        for year in 2009..<lastYear {
            array.append(year.string)
        }
        
        return array.sorted(by: { $0 > $1 })
    }
    
    func setType(_ type: StandingType) {
        standingType = type
    }
    
    func setEvent(_ event: StandingsEvent) {
        selectedEvent = event
    }
    
    func setCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
    }
}

struct StandingsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
