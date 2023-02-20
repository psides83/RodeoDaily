//
//  WatchRodeosListView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchRodeosListView: View {
    @AppStorage("favoriteResultsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteResultsEvent: Events.CodingKeys = .bb
    
    @StateObject var rodeosApi = RodeosApi()
    
    @State var selectedEvent: Events.CodingKeys = .bb
    @State var index = 1
    @State var selectedRodeoId = 0
    @State var showingResults = false
    
    var body: some View {
        Group {
            if rodeosApi.loading {
                WatchLogoLoader()
            } else {
                Form {
                    Picker("Select Event", selection: $selectedEvent) {
                        ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                            Text(event.title)
                                .tag(event)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    ForEach(rodeosApi.rodeos) { rodeo in
                        NavigationLink(rodeo.name) {
                            WatchRodeoResultsView(rodeoId: rodeo.id, rodeoName: rodeo.location, event: selectedEvent)
                        }
                    }
                    
                    VStack(alignment: .center, content: loadMoreButton)
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity)
                        .onChange(of: index) { newValue in
                            Task {
                                await rodeosApi.loadRodeos(event: selectedEvent, index: newValue, searchText: "", dateParams: "") {
                                    rodeosApi.endLoading()
                                }
                            }
                        }
                }
                .navigationTitle("Results")
            }
        }
        .onChange(of: selectedEvent) { newValue in
            Task {
                await rodeosApi.loadRodeos(event: newValue, index: index, searchText: "", dateParams: "") {}
            }
        }
        .task {
            await rodeosApi.loadRodeos(event: favoriteResultsEvent, index: index, searchText: "", dateParams: "") {}
        }
    }
    
    // MARK: - View Methods
    func loadMoreButton() -> some View {
        LoadMoreButton(loading: rodeosApi.loading, action: incrementIndex)
    }
    
    // MARK: - Methods
    func incrementIndex() {
        index += 1
    }
}

struct WatchRodeosListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchRodeosListView()
        }
    }
}
