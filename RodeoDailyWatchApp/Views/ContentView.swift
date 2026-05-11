//
//  ContentView.swift
//  RodeoDailyWatch Watch App
//
//  Created by Payton Sides on 2/18/23.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("standingsWatchWidgetEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDailyWatch")) var standingsWatchWidgetEvent: StandingsEvent = .aa

    enum ViewSelection: String, CaseIterable, Identifiable {
        case standings = "World Standings"
        case results = "Rodeo Results"
        case settings = "Settings"
        
        var id: String { rawValue }
    }
    
    @State var selectedView: ViewSelection = .standings
    @State var showingEvetns = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form(content: viewSelectionListSection)
        }
        .tint(.appSecondary)
        .colorScheme(.dark)
    }
    
    // MARK: - View Methods
    func listHeader() -> some View {
        HStack {
            WatchLogo(size: 28)
            
            Text("Rodeo Daily")
                .font(.headline)
        }
    }
    
    func viewSelectionListSection() -> some View {
        Section(
            header:
                HStack {
                    WatchLogo(size: 28)
                    
                    Text("Rodeo Daily")
                        .font(.headline).textCase(.none)
                },
            content: viewSelectionForEach
        )
    }
    
    func viewSelectionForEach() -> some View {
        ForEach(ViewSelection.allCases, id: \.self, content: viewSelectionListRow)
    }
    
    func viewSelectionListRow(_ view: ViewSelection) -> some View {
        NavigationLink(NSLocalizedString(view.rawValue, comment: "")) {
            switch view {
            case .standings:
                WatchStandingsListView()
            case .results:
                WatchRodeosListView()
            case .settings:
                SettingsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private struct WatchScheduleListView: View {
    @StateObject private var scheduleApi = RodeoScheduleApi()
    @State private var index = 1
    @State private var initialLoad = true

    var body: some View {
        Form {
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
        .navigationTitle("Schedule")
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
                let startDate = parseDate(rodeo.startDate)
                let endDate = parseDate(rodeo.endDate)

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
                let firstDate = parseDate(first.startDate) ?? parseDate(first.endDate) ?? .distantFuture
                let secondDate = parseDate(second.startDate) ?? parseDate(second.endDate) ?? .distantFuture
                return firstDate < secondDate
            }
    }

    private func scheduleDateDisplay(for rodeo: RodeoData) -> String {
        let start = parseDate(rodeo.startDate)
        let end = parseDate(rodeo.endDate)

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

    private func parseDate(_ dateString: String) -> Date? {
        let raw = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let parsed = isoFormatter.date(from: raw) {
            return parsed
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let parsed = isoFormatter.date(from: raw) {
            return parsed
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd",
            "MM/d/yyyy"
        ]

        for format in formats {
            formatter.dateFormat = format
            if let parsed = formatter.date(from: raw) {
                return parsed
            }
        }

        return nil
    }

    private func loadMore() {
        let nextIndex = index + 1
        index = nextIndex

        Task {
            await scheduleApi.loadRodeos(event: .bb, index: nextIndex, searchText: "", dateParams: "") {}
        }
    }
}
