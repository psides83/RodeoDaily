//
//  WatchRodeosListView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchRodeosListView: View {
    // MARK: - Properties
    @AppStorage("resultsWatchEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var resultsWatchEvent: Events.CodingKeys = .bb
    
    @StateObject var rodeosApi = RodeosApi()
    
    @State var selectedEvent: Events.CodingKeys = .bb
    @State var index = 1
    @State var initialLoad = true

    // MARK: - Body
    var body: some View {
        Form {
            Picker("Select Event", selection: $selectedEvent) {
                ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                    Text(event.title)
                        .tag(event)
                }
            }
            .pickerStyle(.navigationLink)

            Group {
                if rodeosApi.loading && rodeosApi.rodeos.isEmpty {
                    WatchLogoLoader()
                        .listRowBackground(Color.clear)
                } else if rodeosApi.rodeos.isEmpty {
                    ContentUnavailableView {
                        Label("No Results", systemImage: "list.number")
                    } description: {
                        Text("No rodeos were found for this event.")
                    }
                } else {
                    ForEach(rodeosApi.rodeos) { rodeo in
                    NavigationLink {
                        WatchRodeoResultsView(rodeoId: rodeo.id, rodeoName: rodeo.location, event: selectedEvent)
                    } label: {
                        WatchRodeoCellView(rodeo: rodeo)
                    }
                }

                    if rodeosApi.loading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
                    VStack(alignment: .center, content: loadMoreButton)
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Results")
        .onChange(of: selectedEvent) { oldValue, newValue in
            resultsWatchEvent = newValue
            index = 1
            Task {
                await rodeosApi.loadRodeos(event: newValue, index: 1, searchText: "", dateParams: "") {}
            }
        }
        .refreshable {
            index = 1
            await rodeosApi.loadRodeos(event: selectedEvent, index: 1, searchText: "", dateParams: "") {}
        }
        .task {
            if initialLoad {
                selectedEvent = resultsWatchEvent
                index = 1
                await rodeosApi.loadRodeos(event: resultsWatchEvent, index: 1, searchText: "", dateParams: "") {}
                initialLoad = false
            }
        }
    }
    
    // MARK: - Computed Views
    
    
    // MARK: - View Methods
    func loadMoreButton() -> some View {
        LoadMoreButton(loading: rodeosApi.loading, action: loadMore)
    }
    
    // MARK: - Methods
    func loadMore() {
        let nextIndex = index + 1
        index = nextIndex
        
        Task {
            await rodeosApi.loadRodeos(event: selectedEvent, index: nextIndex, searchText: "", dateParams: "") {}
        }
    }
}

struct WatchRodeosListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchRodeosListView()
        }
    }
}
