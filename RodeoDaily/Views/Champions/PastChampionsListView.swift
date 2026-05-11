import SwiftUI

struct PastChampionsListView: View {
    @StateObject private var api = PastChampionsApi()
    @State private var searchText = ""
    @State private var selectedEvent = NSLocalizedString("All Events", comment: "")

    var body: some View {
        List {
            if api.loading && api.champions.isEmpty {
                ProgressView()
                    .hSpacing(.center)
            } else if filteredChampions.isEmpty {
                ContentUnavailableView {
                    Label("No Champions Found", systemImage: "rosette")
                } description: {
                    Text(api.errorMessage ?? "Try changing search or event filters.")
                }
            } else if selectedEvent == allEventsTitle {
                ForEach(groupedByYear, id: \.year) { group in
                    Section(group.year) {
                        ForEach(group.champions) { champion in
                            championRow(champion)
                        }
                    }
                }
            } else {
                Section {
                    ForEach(topChampions, id: \.name) { item in
                        HStack {
                            Text(item.name)
                                .font(.appBodyStrong)
                            Spacer()
                            Text("\(item.titles) \(NSLocalizedString("titles", comment: ""))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(NSLocalizedString("Most World Titles", comment: ""))
                }

                ForEach(filteredChampions) { champion in
                    championRow(champion)
                }
            }
        }
        .searchable(text: $searchText, prompt: NSLocalizedString("Search champions", comment: ""))
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(eventOptions, id: \.self) { event in
                        Button(event) {
                            selectedEvent = event
                        }
                    }
                } label: {
                    Label(selectedEvent, systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .task {
            await api.load()
        }
        .refreshable {
            await api.load()
        }
    }

    private var allEventsTitle: String {
        NSLocalizedString("All Events", comment: "")
    }

    private var navigationTitle: String {
        if selectedEvent == allEventsTitle {
            return NSLocalizedString("Past Champions", comment: "")
        }
        return "\(selectedEvent)"
    }

    private var eventOptions: [String] {
        let events = Set(api.champions.map(\.event))
        return [allEventsTitle] + events.sorted()
    }

    private var filteredChampions: [PastChampion] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return api.champions
            .filter { champion in
                guard selectedEvent != allEventsTitle else { return true }
                return champion.event == selectedEvent
            }
            .filter { champion in
                guard !trimmed.isEmpty else { return true }
                return champion.athlete.localizedCaseInsensitiveContains(trimmed)
                    || champion.event.localizedCaseInsensitiveContains(trimmed)
                    || champion.year.localizedCaseInsensitiveContains(trimmed)
                    || (champion.hometown?.localizedCaseInsensitiveContains(trimmed) ?? false)
            }
            .sorted { lhs, rhs in
                if lhs.yearValue == rhs.yearValue {
                    if lhs.event == rhs.event {
                        return lhs.athlete < rhs.athlete
                    }
                    return lhs.event < rhs.event
                }
                return lhs.yearValue > rhs.yearValue
            }
    }

    private var groupedByYear: [(year: String, champions: [PastChampion])] {
        let grouped = Dictionary(grouping: filteredChampions, by: \.year)
        return grouped
            .map { key, value in
                (year: key, champions: value.sorted { lhs, rhs in
                    if lhs.event == rhs.event {
                        return lhs.athlete < rhs.athlete
                    }
                    return lhs.event < rhs.event
                })
            }
            .sorted { lhs, rhs in
                (Int(lhs.year) ?? 0) > (Int(rhs.year) ?? 0)
            }
    }

    private var eventFilteredChampions: [PastChampion] {
        api.champions.filter { $0.event == selectedEvent }
    }

    private var topChampions: [(name: String, titles: Int)] {
        let counts = Dictionary(grouping: eventFilteredChampions, by: \.athlete)
            .map { key, value in (name: key, titles: value.count) }
            .sorted { lhs, rhs in
                if lhs.titles == rhs.titles {
                    return lhs.name < rhs.name
                }
                return lhs.titles > rhs.titles
            }
        return Array(counts.prefix(5))
    }

    private func championRow(_ champion: PastChampion) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(champion.athlete)
                    .font(.appBodyStrong)
                Spacer()
                Text(champion.year)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if selectedEvent == allEventsTitle {
                Text(champion.event)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let hometown = champion.hometown, !hometown.isEmpty {
                Text(hometown)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
