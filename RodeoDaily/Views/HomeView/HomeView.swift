//
//  HomeView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/16/22.
//

import SwiftUI

extension HomeView {
    //MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let safeAreaTop = proxy.safeAreaInsets.top
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        HeaderView(safeAreaTop)
                            .offset(y: -offSetY)
                            .zIndex(1)
                        
                        VStack {
                            /// Scroll Content Goes Here
                            switch selectedTab {
                                
                            case .standings:
                                StandingsList(standings: standingsApi.standings, loading: standingsApi.loading, selectedTab: selectedTab, searchText: searchText, selectedYear: $selectedYear, selectedEvent: $standingsEvent, standingType: $standingType, selectedCircuit: $circuit)
                           
                            case .results:
                                ResultsList(rodeos: rodeosApi.rodeos, dateParams: dateParams, loading: rodeosApi.loading, selectedEvent: $resultsEvent, index: $index, dateRange: $dateRange)
                           
                            case .cowboys:
                                EmptyView()
                            }
                            
                        }
                        .onChange(of: resultsEvent) { newValue in
                            Task {
                                if selectedTab == .results {
                                    await rodeosApi.loadRodeos(event: resultsEvent, index: index, searchText: searchText, dateParams: dateParams) {
                                        rodeosApi.endLoading()
                                    }
                                }
                            }
                        }
                        .onChange(of: index) { newValue in
                            Task {
                                if selectedTab == .results {
                                    await rodeosApi.loadRodeos(event: resultsEvent, index: newValue, searchText: searchText, dateParams: dateParams) {
                                        rodeosApi.endLoading()
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedTab) { newValue in
                            Task {
                                if newValue == .standings {
                                    clearSearch()
//                                    await standingsApi.getStandings(for: standingsEvent, type: standingType, circuit: circuit, selectedYear: selectedYear)
                                }
                                
                                if newValue == .results {
                                    clearSearch()
                                    await rodeosApi.loadRodeos(event: resultsEvent, index: index, searchText: "", dateParams: dateParams) {
                                        rodeosApi.endLoading()
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedYear) { newValue in
                            Task {
                                await standingsApi.getStandings(for: standingsEvent, type: standingType, circuit: circuit, selectedYear: newValue)
                            }
                        }
                        .onChange(of: standingsEvent) { newValue in
                            Task {
                                await standingsApi.getStandings(for: newValue, type: standingType, circuit: circuit, selectedYear: selectedYear)
                            }
                        }
                        .onChange(of: standingType) { newValue in
                            Task {
                                await standingsApi.getStandings(for: standingsEvent, type: newValue, circuit: circuit, selectedYear: selectedYear)
                            }
                        }
                        .onChange(of: circuit) { newValue in
                            Task {
                                await standingsApi.getStandings(for: standingsEvent, type: standingType, circuit: newValue, selectedYear: selectedYear)
                            }
                        }
                        .onChange(of: dateRange) { newValue in
                            Task {
                                if !dateParams.isEmpty {
                                    print("date load ran")
                                    await rodeosApi.loadRodeos(for: resultsEvent, in: dateParams, with: searchText) {
                                        rodeosApi.endLoading()
                                    }
                                    
                                    if rodeosApi.rodeos.count == 0 {
                                        rodeosApi.endLoading()
                                    }
                                }
                                
                                if newValue.count == 0 {
                                    await rodeosApi.loadRodeos(event: resultsEvent, index: 1, searchText: searchText, dateParams: dateParams) {
                                        rodeosApi.endLoading()
                                    }
                                }
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
                                    await rodeosApi.loadRodeos(event: resultsEvent, index: index, searchText: "", dateParams: dateParams) {
                                        initialLoad = false
                                    }
                                }
                            }
                        }
                        .padding()
                        .zIndex(0)
                    }
                    .offset(coordinateSpcae: .named(coordinateSpace)) { offset in
                        offSetY = offset
                        isShowingSearchBar = (-offset > 80) && isShowingSearchBar
                    }
                }
                .background(Color.appBg)
                .coordinateSpace(name: coordinateSpace)
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
}
