//
//  HomeMainView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/16/23.
//

import Foundation
import SwiftUI

extension HomeView {
    func Main(safeAreaTop: CGFloat) -> some View {
        VStack {
            /// Scroll Content Goes Here
            switch selectedTab {
            case .standings:
                StandingsList(
                    widgetAthletes: widgetAthletes,
                    followedAthletes: followedAthletes,
                    standings: standingsApi.standings,
                    loading: standingsApi.loading,
                    selectedTab: selectedTab,
                    searchText: search.text,
                    selectedYear: $selectedYear,
                    selectedEvent: $standingsEvent,
                    standingType: $standingType,
                    selectedCircuit: $circuit
                )
                
            case .results:
                ResultsList(
                    rodeos: rodeosApi.rodeos,
                    loading: rodeosApi.loading,
                    widgetAthletes: widgetAthletes,
                    selectedEvent: $resultsEvent,
                    index: $index,
                    dateRange: $dateRange
                )

            case .more:
                MoreView()
            }
        }
        .onChange(of: selectedYear) { old, newValue in
            Task {
                await standingsApi.getStandings(
                    for: standingsEvent,
                    type: standingType,
                    circuit: circuit,
                    selectedYear: newValue
                )
            }
        }
        .onAppear {
            if initialLoad {
                standingsEvent = favoriteStandingsEvent
                resultsEvent = favoriteResultsEvent
            }
        }
        .task {
            if initialLoad {
                if selectedTab == .standings {
                    await standingsApi.getStandings(
                        for: favoriteStandingsEvent,
                        selectedYear: selectedYear
                    )
                    initialLoad = false
                }
                
                if selectedTab == .results {
                    await rodeosApi.loadRodeos(
                        event: resultsEvent,
                        index: index,
                        searchText: "",
                        dateParams: dateParams
                    ) {
                        initialLoad = false
                    }
                }
            }
        }
        .padding()
        .zIndex(0)
        
    }
}
