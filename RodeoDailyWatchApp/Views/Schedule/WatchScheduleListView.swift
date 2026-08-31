//
//  WatchScheduleListView.swift
//  RodeoDailyWatchApp
//

import SwiftUI

struct WatchScheduleListView: View {
    @StateObject private var scheduleApi = RodeoScheduleApi()
    @State private var index = 1
    @State private var initialLoad = true

    var body: some View {
        List {
            if scheduleApi.loading && scheduleApi.rodeos.isEmpty {
                WatchLogoLoader()
                    .listRowBackground(Color.clear)
            } else if upcomingRodeos.isEmpty {
                ContentUnavailableView {
                    Label("No Upcoming Rodeos", systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text("There are no current or upcoming rodeos right now.")
                }
            } else {
                Section {
                    ForEach(upcomingRodeos) { rodeo in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(rodeo.name)
                                .font(.headline)
                                .lineLimit(2)

                            Text(rodeo.location)
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)

                            Text(scheduleDateDisplay(for: rodeo))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                } header: {
                    WatchListHeader(
                        title: "\(upcomingRodeos.count) Upcoming",
                        subtitle: "Sorted by date",
                        systemImage: "calendar"
                    )
                }

                if scheduleApi.loading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    LoadMoreButton(loading: scheduleApi.loading) {
                        loadMore()
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WatchToolbarIconButton(
                    systemImage: "arrow.clockwise",
                    accessibilityLabel: "Refresh Schedule",
                    isDisabled: scheduleApi.loading
                ) {
                    index = 1
                    Task {
                        await scheduleApi.loadRodeos(event: .bb, index: 1, searchText: "", dateParams: "") {}
                    }
                }
            }
        }
        .refreshable {
            index = 1
            await scheduleApi.loadRodeos(event: .bb, index: 1, searchText: "", dateParams: "") {}
        }
        .task {
            if initialLoad {
                await scheduleApi.loadRodeos(event: .bb, index: 1, searchText: "", dateParams: "") {}
                initialLoad = false
            }
        }
    }

    private var upcomingRodeos: [RodeoData] {
        let startOfToday = Calendar.current.startOfDay(for: Date())

        return scheduleApi.rodeos
            .filter { rodeo in
                let startDate = rodeo.startDate.rodeoDate
                let endDate = rodeo.endDate.rodeoDate

                switch (startDate, endDate) {
                case let (start?, end?):
                    return start >= startOfToday || end >= startOfToday
                case let (start?, nil):
                    return start >= startOfToday
                case let (nil, end?):
                    return end >= startOfToday
                case (nil, nil):
                    return false
                }
            }
            .sorted { first, second in
                let firstDate = first.startDate.rodeoDate ?? first.endDate.rodeoDate ?? .distantFuture
                let secondDate = second.startDate.rodeoDate ?? second.endDate.rodeoDate ?? .distantFuture
                return firstDate < secondDate
            }
    }

    private func scheduleDateDisplay(for rodeo: RodeoData) -> String {
        let start = rodeo.startDate.rodeoDate
        let end = rodeo.endDate.rodeoDate

        if let start, let end {
            if Calendar.current.isDate(start, inSameDayAs: end) {
                return start.dateOnly
            }

            return "\(start.dateOnly) - \(end.dateOnly)"
        }

        if let start {
            return start.dateOnly
        }

        if let end {
            return end.dateOnly
        }

        return ""
    }

    private func loadMore() {
        let nextIndex = index + 1
        index = nextIndex

        Task {
            await scheduleApi.loadRodeos(event: .bb, index: nextIndex, searchText: "", dateParams: "") {}
        }
    }
}
