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
                    standings: standingsApi.standings,
                    loading: standingsApi.loading,
                    selectedTab: selectedTab,
                    searchText: search.text,
                    selectedYear: $selectedYear,
                    selectedEvent: $standingsEvent,
                    standingType: $standingType,
                    selectedCircuit: $circuit
                )
                .onChange(of: standingsEvent) { old, newValue in
                    Task {
                        await standingsApi.getStandings(
                            for: newValue,
                            type: standingType,
                            circuit: circuit,
                            selectedYear: selectedYear
                        )
                    }
                }
                .onChange(of: standingType) { old, newValue in
                    Task {
                        await standingsApi.getStandings(
                            for: standingsEvent,
                            type: newValue,
                            circuit: circuit,
                            selectedYear: selectedYear
                        )
                    }
                }
                .onChange(of: circuit) { old, newValue in
                    Task {
                        await standingsApi.getStandings(
                            for: standingsEvent,
                            type: standingType,
                            circuit: newValue,
                            selectedYear: selectedYear
                        )
                    }
                }
                
            case .results:
                ResultsList(
                    rodeos: rodeosApi.rodeos,
                    loading: rodeosApi.loading,
                    widgetAthletes: widgetAthletes,
                    selectedEvent: $resultsEvent,
                    index: $index,
                    dateRange: $dateRange
                )
                .onChange(of: resultsEvent) {
                    Task {
                        if selectedTab == .results {
                            await rodeosApi.loadRodeos(
                                event: resultsEvent,
                                index: index,
                                searchText: search.text,
                                dateParams: dateParams
                            ) { rodeosApi.endLoading() }
                        }
                    }
                }
                .onChange(of: index) { old, newValue in
                    Task {
                        if selectedTab == .results {
                            await rodeosApi.loadRodeos(
                                event: resultsEvent,
                                index: newValue,
                                searchText: search.text,
                                dateParams: dateParams
                            ) { rodeosApi.endLoading() }
                        }
                    }
                }
                .onChange(of: dateRange) { old, newValue in
                    Task {
                        if !dateParams.isEmpty {
//                            print("date load ran")
                            await rodeosApi.loadRodeos(
                                for: resultsEvent,
                                in: dateParams,
                                with: search.text
                            ) { rodeosApi.endLoading() }
                            
                            if rodeosApi.rodeos.count == 0 {
                                rodeosApi.endLoading()
                            }
                        }
                        
                        if newValue.count == 0 {
                            await rodeosApi.loadRodeos(
                                event: resultsEvent,
                                index: 1,
                                searchText: search.text,
                                dateParams: dateParams
                            ) { rodeosApi.endLoading() }
                        }
                    }
                }
                
            case .cowboys:
                AthletesView(searchText: search.text)
            }
        }
        .onChange(of: selectedTab) { old, newValue in
            Task {
                if newValue == .standings {
                    clearSearch()
//                    await standingsApi.getStandings(for: standingsEvent, type: standingType, circuit: circuit, selectedYear: selectedYear)
                }
                
                if newValue == .results {
                    clearSearch()
                    await rodeosApi.loadRodeos(
                        event: resultsEvent,
                        index: index,
                        searchText: "",
                        dateParams: dateParams
                    ) { rodeosApi.endLoading() }
                }
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
                    await standingsApi.getStandings(for: standingsEvent, selectedYear: selectedYear)
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
