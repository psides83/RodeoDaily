//
//  NFRStandingsView.swift
//  RodeoDaily
//

import SwiftUI

struct NFRStandingsView: View {
    @StateObject private var api = NFRStandingsApi()
    @State private var selectedEvent: StandingsEvent = .bb
    @State private var selectedSort: NFRStandingsSort = .averagePlace
    @State private var didInitialLoad = false

    private let events: [StandingsEvent] = [.bb, .sw, .hd, .hl, .sb, .td, .gb, .br]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpace.xxl) {
                header

                if api.loading && api.standings.isEmpty {
                    StandingsLoader()
                } else if let errorMessage = api.errorMessage {
                    UnavailableContentView(
                        imageName: "exclamationmark.triangle",
                        title: NSLocalizedString("NFR standings unavailable", comment: ""),
                        description: errorMessage
                    )
                } else if api.standings.isEmpty {
                    UnavailableContentView(
                        imageName: "list.number",
                        title: NSLocalizedString("No NFR standings found", comment: ""),
                        description: NSLocalizedString("Check back once rankings are posted for this event.", comment: "")
                    )
                } else {
                    LazyVStack(spacing: AppSpace.lg) {
                        ForEach(sortedStandings) { contestant in
                            NFRContestantCard(contestant: contestant)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .navigationTitle("NFR")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !didInitialLoad else { return }
            didInitialLoad = true
            await api.load(event: selectedEvent)
        }
        .onChange(of: selectedEvent) { _, newValue in
            Task {
                await api.load(event: newValue)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpace.lg) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: AppSpace.xs) {
                    Text("NFR")
                        .foregroundColor(.appPrimary)
                        .font(.appSectionTitle)
                        .fontWeight(.bold)

                    Text(selectedEvent.localizedTitle)
                        .foregroundColor(.appSecondary)
                        .font(.appCardTitle)
                        .fontWeight(.bold)
                }

                Spacer()

                HStack(spacing: AppSpace.sm) {
                    Menu {
                        ForEach(events, id: \.self) { event in
                            Button(event.localizedTitle) {
                                selectedEvent = event
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appPrimary)
                            .frame(width: 34, height: 34)
                            .background(
                                Circle()
                                    .fill(Color.appSecondary.opacity(0.10))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.appTertiary.opacity(0.30), lineWidth: AppStroke.hairline)
                            )
                    }
                    .accessibilityLabel(Text(NSLocalizedString("Filter NFR event", comment: "")))

                    sortMenu
                }
            }

            HStack(spacing: AppSpace.sm) {
                if let currentRound = api.standings.first?.currentRound {
                    Text(
                        String(
                            format: NSLocalizedString("Current through Round %d", comment: ""),
                            currentRound
                        )
                    )
                }

                Text(
                    String(
                        format: NSLocalizedString("Sorted by %@", comment: ""),
                        selectedSort.title
                    )
                )
            }
            .font(.appCaptionStrong)
            .foregroundColor(.appSecondary)
        }
        .appCardStyle()
    }

    private var sortMenu: some View {
        Menu {
            ForEach(NFRStandingsSort.allCases) { sort in
                Button {
                    selectedSort = sort
                } label: {
                    Label(sort.title, systemImage: selectedSort == sort ? "checkmark" : "")
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.appPrimary)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.appSecondary.opacity(0.10))
                )
                .overlay(
                    Circle()
                        .stroke(Color.appTertiary.opacity(0.30), lineWidth: AppStroke.hairline)
                )
        }
        .accessibilityLabel(Text(NSLocalizedString("Sort NFR standings", comment: "")))
    }

    private var sortedStandings: [NFRContestant] {
        api.standings.sorted { lhs, rhs in
            selectedSort.areInIncreasingOrder(lhs, rhs)
        }
    }
}

private enum NFRStandingsSort: String, CaseIterable, Identifiable {
    case worldRank
    case averagePlace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .worldRank: return NSLocalizedString("World Standings", comment: "")
        case .averagePlace: return NSLocalizedString("Average", comment: "")
        }
    }

    func areInIncreasingOrder(_ lhs: NFRContestant, _ rhs: NFRContestant) -> Bool {
        switch self {
        case .worldRank:
            if lhs.worldPlace == rhs.worldPlace {
                return lhs.averagePlace < rhs.averagePlace
            }
            return lhs.worldPlace < rhs.worldPlace
        case .averagePlace:
            if lhs.averagePlace == rhs.averagePlace {
                return lhs.worldPlace < rhs.worldPlace
            }
            return lhs.averagePlace < rhs.averagePlace
        }
    }
}

#Preview {
    NavigationStack {
        NFRStandingsView()
    }
}
