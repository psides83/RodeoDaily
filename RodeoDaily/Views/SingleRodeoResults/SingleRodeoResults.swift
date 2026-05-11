//
//  SingleRodeoResults.swift
//  RodeoDaily
//
//  Created by Payton Sides on 6/19/25.
//

import SwiftUI

struct SingleRodeoResults: View {
    @StateObject private var resultsApi = ResultsApi()
    @State private var isShowingBracketHelp = false
    @State private var isShowingShareRangeOptions = false
    @State private var isShowingShareSheet = false
    @State private var shareItems: [Any] = []
    
    let rodeoId: Int
    let rodeoName: String
    let location: String
    let endDate: String
    let event: Events.CodingKeys
    
    let helpMessage: LocalizedStringKey = "For rodeos like **RODEOHOUSTON** where rounds are broken up into ***brackets***, all the bracket's winners are lumped into the given round in the results. You might see multiple athletes who placed 1st and won the same money but all with different times/scores in a given round. This is due to the ***bracket format***."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.xxl) {
                header
                
                if resultsApi.loading {
                    ResultsLoader()
                } else if resultsApi.results.rounds.isEmpty {
                    ContentUnavailableView {
                        Label("No Results Found", systemImage: "list.number")
                            .foregroundColor(.appPrimary)
                    } description: {
                        Text("We were not able to load the full results for this rodeo.")
                            .foregroundColor(.appPrimary)
                    }
                } else {
                    roundsList
                }
            }
            .padding()
        }
        .background(Color.appBg)
        .navigationTitle(rodeoName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingBracketHelp) {
            VStack {
                Text("**Important**")
                    .font(.largeTitle)
                
                Text(helpMessage)
                    .font(.title3)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.rdGreen.edgesIgnoringSafeArea(.all))
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .foregroundColor(.white)
        }
        .task {
            await resultsApi.loadResults(rodeoId: rodeoId, event: event) {
                resultsApi.endLoading()
            }
        }
        .confirmationDialog(
            NSLocalizedString("Share Results", comment: ""),
            isPresented: $isShowingShareRangeOptions,
            titleVisibility: .visible
        ) {
            ForEach(availableShareRanges, id: \.self) { option in
                Button(option.title) {
                    prepareResultsShare(for: option)
                }
            }
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) { }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            AppShareSheet(items: shareItems)
        }
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text(event.title)
                    .foregroundColor(.appSecondary)
                    .font(.appSectionTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    isShowingBracketHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .foregroundColor(.appSecondary)
                        .padding(AppSpace.sm)
                        .background(
                            Circle()
                                .fill(Color.appBg)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Bracket Help")

//                Button {
//                    isShowingShareRangeOptions = true
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.title3)
//                        .foregroundColor(.appSecondary)
//                        .padding(AppSpace.sm)
//                        .background(
//                            Circle()
//                                .fill(Color.appBg)
//                        )
//                        .overlay(
//                            Circle()
//                                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
//                        )
//                }
//                .buttonStyle(.plain)
//                .accessibilityLabel("Share results")
            }

            Text(rodeoName)
                .foregroundColor(.appPrimary)
                .font(.appCardTitle)
                .fontWeight(.bold)
                .lineLimit(3)

            HStack(spacing: AppSpace.xs) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.appSecondary)
                    .font(.appCaptionStrong)

                Text(location)
                    .font(.appBody)
                    .foregroundColor(.appPrimary)
                    .lineLimit(1)

                Circle()
                    .fill(Color.appSecondary)
                    .frame(width: 4, height: 4)

                Text(endDate.medium)
                    .font(.appCaptionStrong)
                    .foregroundColor(.appTertiary)
                    .lineLimit(1)
            }
        }
        .appCardStyle()
    }
    
    var roundsList: some View {
        let roundCount = resultsApi.results.rounds.count
        
        return VStack(spacing: AppSpace.md) {
            ForEach(resultsApi.results.rounds, id: \.id) { round in
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(round.roundDisplay(roundCount: roundCount))
                            .foregroundColor(.appSecondary)
                            .font(.appRowTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(event == .tr ? "Time" : "Result")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        
                        Text("Earnings")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                            .frame(width: 80, alignment: .trailing)
                    }
                    
                    if event == .tr {
                        let teamResults = teams(from: round)
                        
                        ForEach(teamResults) { team in
                            teamRow(team)
                            
                            if team.id != teamResults.last?.id {
                                Divider()
                                    .overlay(Color.appTertiary.opacity(0.25))
                            }
                        }
                    } else {
                        ForEach(round.winners) { winner in
                            winnerRow(winner)
                            
                            if winner.id != round.winners.last?.id {
                                Divider()
                                    .overlay(Color.appTertiary.opacity(0.25))
                            }
                        }
                    }
                }
                .appCardStyle()
                
                BannerAd(style: .mediumRectangle)
            }
        }
    }
    
    func winnerRow(_ winner: Winner) -> some View {
        HStack(alignment: .center, spacing: AppSpace.xs) {
            Text(winner.placeDisplay)
                .font(.appRank)
                .foregroundColor(.appSecondary)
                .frame(width: 24, alignment: .leading)
            
            winner.image
                .scaleEffect(0.95)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                NavigationLink {
                    BioView(athleteId: winner.contestantId)
                } label: {
                    Text(winner.name)
                        .foregroundColor(.appPrimary)
                        .font(.appBodyStrong)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(2)
                }
                .buttonStyle(.plain)
                
                Text(winner.hometownDisplay)
                    .foregroundColor(.appTertiary)
                    .font(.appCaption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .allowsTightening(true)
                    .layoutPriority(1)
            }
            .layoutPriority(1)
            
            Spacer()
            
            Text(winner.result)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.appPrimary)
                .monospacedDigit()
                .frame(width: 58, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(winner.earnings)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.appPrimary)
                .monospacedDigit()
                .frame(width: 80, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
    
    func teamRow(_ team: Team) -> some View {
        HStack(alignment: .top, spacing: AppSpace.xs) {
            Text(team.place)
                .font(.appRank)
                .foregroundColor(.appSecondary)
                .frame(width: 24, alignment: .leading)
            
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                HStack(spacing: AppSpace.xs) {
                    team.headerImage
                        .scaleEffect(0.9)
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: AppSpace.xxs) {
                        Text("H")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        
                        NavigationLink {
                            BioView(athleteId: team.headerId)
                        } label: {
                            Text(team.headerName)
                                .foregroundColor(.appPrimary)
                                .font(.appBody)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack(spacing: AppSpace.xs) {
                    team.heelerImage
                        .scaleEffect(0.9)
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: AppSpace.xxs) {
                        Text("He")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        
                        NavigationLink {
                            BioView(athleteId: team.heelerId)
                        } label: {
                            Text(team.heelerName)
                                .foregroundColor(.appPrimary)
                                .font(.appBody)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
            
            Text(team.time)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.appPrimary)
                .monospacedDigit()
                .frame(width: 58, alignment: .trailing)
            
            Text(team.payoff)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.appPrimary)
                .monospacedDigit()
                .frame(width: 80, alignment: .trailing)
        }
    }
    
    func teams(from round: RoundWinners) -> [Team] {
        var addedTeams = [Int]()
        var teams = [Team]()
        
        round.winners.forEach { winner in
            let isCurrentTeam = addedTeams.filter({ $0 == winner.teamId }).count > 0
            let teamArray = round.winners.filter({ $0.teamId == winner.teamId })
            
            guard teamArray.count == 2 else {
                return
            }
            
            let header = teamArray[0]
            let heeler = teamArray[1]
            
            let team = Team(
                id: header.teamId,
                headerId: header.contestantId,
                headerName: header.name,
                heelerId: heeler.contestantId,
                heelerName: heeler.name,
                roundLabel: header.roundLabel,
                place: header.placeDisplay,
                headerHometown: header.hometownDisplay,
                heelerHometown: heeler.hometownDisplay,
                headerImageUrl: header.imageUrl,
                heelerImageUrl: heeler.imageUrl,
                payoff: header.earnings,
                time: header.result,
                round: header.round
            )
            
            if !isCurrentTeam {
                addedTeams.append(winner.teamId)
                teams.append(team)
            }
        }
        
        return teams
    }

    private var flatWinnersForShare: [Winner] {
        resultsApi.results.rounds
            .flatMap(\.winners)
            .sorted { lhs, rhs in
                if lhs.place == rhs.place {
                    return lhs.payoff > rhs.payoff
                }
                return lhs.place < rhs.place
            }
    }

    private var availableShareRanges: [ShareRangeOption] {
        let count = flatWinnersForShare.count
        return ShareRangeOption.defaultRanges.filter { $0.count <= count }
    }

    private func prepareResultsShare(for option: ShareRangeOption) {
        let winners = Array(flatWinnersForShare.prefix(option.count))
        guard !winners.isEmpty else { return }

        let snapshot = RodeoResultsShareCardView(
            eventTitle: event.title,
            rodeoName: rodeoName,
            location: location,
            dateText: endDate.medium,
            rangeTitle: option.title,
            winners: winners
        )

        guard let image = snapshot.shareSnapshotImage() else { return }
        let link = URL(string: "https://rodeodaily.app") ?? URL(string: "https://apps.apple.com")!
        let message = "\(NSLocalizedString("Check out these rodeo results on Rodeo Daily.", comment: ""))\n\(link.absoluteString)"
        shareItems = [image, message]
        isShowingShareSheet = true
    }
}

private struct RodeoResultsShareCardView: View {
    let eventTitle: String
    let rodeoName: String
    let location: String
    let dateText: String
    let rangeTitle: String
    let winners: [Winner]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image.appLogo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Spacer()
                Text(rangeTitle)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appSecondary)
            }

            Text("Rodeo Daily")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appPrimary)
            Text(eventTitle)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.appSecondary)
            Text(rodeoName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(2)
            Text("\(location) • \(dateText)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            VStack(spacing: 12) {
                ForEach(Array(winners.enumerated()), id: \.offset) { _, winner in
                    HStack(spacing: 10) {
                        Text(winner.placeDisplay)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.appSecondary)
                            .frame(width: 36, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(winner.name)
                                .font(.title3.weight(.semibold))
                                .lineLimit(1)
                            Text(winner.hometownDisplay)
                                .font(.title3.weight(.regular))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(winner.result)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.appPrimary)
                                .monospacedDigit()
                            Text(winner.earningsABS)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.appSecondary)
                                .monospacedDigit()
                        }
                    }
                }
            }

            Text(NSLocalizedString("Get Rodeo Daily", comment: ""))
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 1080, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.appBg, Color.rdGreen.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private extension View {
    func shareSnapshotImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        return renderer.uiImage
    }
}



#Preview {
    NavigationStack {
        SingleRodeoResults(
            rodeoId: 0,
            rodeoName: "Rodeo",
            location: "Fort Worth, TX",
            endDate: "2026-02-19T00:00:00",
            event: .td
        )
    }
}
