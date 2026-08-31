//
//  WatchRodeosListView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchRodeosListView: View {
    // MARK: - Properties
    @AppStorage(
        FavoriteEventSettingsSync.favoriteResultsEventKey,
        store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")
    )
    var favoriteResultsEvent: Events.CodingKeys = .bb
    
    @StateObject var rodeosApi = RodeosApi()
    
    @State var selectedEvent: Events.CodingKeys = .bb
    @State var index = 1
    @State var initialLoad = true

    // MARK: - Body
    var body: some View {
        List {
            Section {
                Picker("Event", selection: $selectedEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.localizedTitle)
                            .tag(event)
                    }
                }
                .pickerStyle(.navigationLink)
            } header: {
                WatchListHeader(
                    title: selectedEvent.localizedTitle,
                    subtitle: "\(rodeosApi.rodeos.count) rodeos",
                    systemImage: "trophy"
                )
            }

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
        .listStyle(.carousel)
        .navigationTitle("Results")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WatchToolbarIconButton(
                    systemImage: "arrow.clockwise",
                    accessibilityLabel: "Refresh Results",
                    isDisabled: rodeosApi.loading
                ) {
                    index = 1
                    Task {
                        await rodeosApi.loadRodeos(event: selectedEvent, index: 1, searchText: "", dateParams: "") {}
                    }
                }
            }
        }
        .onChange(of: selectedEvent) { oldValue, newValue in
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
                selectedEvent = favoriteResultsEvent
                index = 1
                await rodeosApi.loadRodeos(event: favoriteResultsEvent, index: 1, searchText: "", dateParams: "") {}
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
