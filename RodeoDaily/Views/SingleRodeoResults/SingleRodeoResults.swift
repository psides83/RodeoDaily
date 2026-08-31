//
//  SingleRodeoResults.swift
//  RodeoDaily
//
//  Created by Payton Sides on 6/19/25.
//

import SwiftData
import SwiftUI
import WidgetKit

private enum ResultsDetailContent: String, CaseIterable, Identifiable {
    case results
    case daysheets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .results: return "Results"
        case .daysheets: return "Daysheets"
        }
    }
}

struct SingleRodeoResults: View {
    private static let selectedContentDefaultsKey = "lastRodeoResultsDetailContent"

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WidgetAthlete.sortOrder) private var widgetAthletes: [WidgetAthlete]
    @StateObject private var resultsApi = ResultsApi()
    @State private var selectedEvent: Events.CodingKeys
    @State private var selectedContent: ResultsDetailContent
    @State private var isShowingBracketHelp = false
    @State private var isShowingShareRangeOptions = false
    @State private var isShowingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var daysheets = [ScheduleDaysheet]()
    @State private var daysheetsLoading = false
    @State private var daysheetsError: String?
    @Namespace private var eventChipNamespace
    
    let rodeoId: Int
    let rodeoName: String
    let location: String
    let endDate: String
    let hasDaysheets: Bool
    
    let helpMessage: LocalizedStringKey = "For rodeos like **RODEOHOUSTON** where rounds are broken up into ***brackets***, all the bracket's winners are lumped into the given round in the results. You might see multiple athletes who placed 1st and won the same money but all with different times/scores in a given round. This is due to the ***bracket format***."

    init(
        rodeoId: Int,
        rodeoName: String,
        location: String,
        endDate: String,
        event: Events.CodingKeys,
        hasDaysheets: Bool = false
    ) {
        self.rodeoId = rodeoId
        self.rodeoName = rodeoName
        self.location = location
        self.endDate = endDate
        self.hasDaysheets = hasDaysheets
        _selectedEvent = State(initialValue: event)

        let savedContent = UserDefaults.standard.string(forKey: Self.selectedContentDefaultsKey)
            .flatMap(ResultsDetailContent.init(rawValue:))
        _selectedContent = State(initialValue: hasDaysheets ? savedContent ?? .results : .results)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.sm) {
                header

                if hasDaysheets {
                    contentPicker
                }

                eventFilter

                selectedContentView
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
        .task(id: selectedEvent) {
            resultsApi.setLoading()
            await resultsApi.loadResults(rodeoId: rodeoId, event: selectedEvent) {
                resultsApi.endLoading()
            }
        }
        .task {
            await loadDaysheetsIfNeeded()
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
        .onChange(of: selectedContent) { _, newValue in
            guard hasDaysheets else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: Self.selectedContentDefaultsKey)
        }
    }

    @ViewBuilder
    private var selectedContentView: some View {
        switch selectedContent {
        case .results:
            resultsSection
        case .daysheets:
            daysheetsSection
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if resultsApi.loading {
            ResultsLoader()
        } else if resultsApi.results.rounds.isEmpty {
            ContentUnavailableView {
                Label("No Results Found", systemImage: "list.number")
                    .foregroundColor(.appPrimary)
            } description: {
                Text("We were not able to load the full results for this rodeo.")
                    .foregroundColor(.appPrimary)
            } actions: {
                Menu {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Button(event.title) {
                            withAnimation {
                                selectedEvent = event
                            }
                        }
                    }
                } label: {
                    Label("Change Event", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.loadingButton(false))
            }
        } else {
            roundsList
        }
    }

    private var contentPicker: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text("View")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .padding(.horizontal, AppSpace.xs)

            HStack(spacing: AppSpace.sm) {
                ForEach(ResultsDetailContent.allCases) { content in
                    contentChip(for: content)
                }
            }
            .padding(.horizontal, AppSpace.xs)
            .padding(.vertical, AppSpace.xs)
        }
        .padding(.vertical, AppSpace.xs)
        .accessibilityLabel("Show results or daysheets")
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text(selectedContent == .daysheets ? "Daysheets" : selectedEvent.title)
                    .foregroundColor(.appSecondary)
                    .font(.appSectionTitle)
                    .fontWeight(.bold)
                
                Spacer()

                if selectedContent == .results {
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
                }

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

    private var eventFilter: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            Text("Event")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .padding(.horizontal, AppSpace.xs)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpace.sm) {
                        ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                            eventChip(for: event)
                                .id(event)
                        }
                    }
                    .padding(.horizontal, AppSpace.xs)
                    .padding(.vertical, AppSpace.xs)
                }
                .onAppear {
                    proxy.scrollTo(selectedEvent, anchor: .center)
                }
                .onChange(of: selectedEvent) { _, newValue in
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .padding(.vertical, AppSpace.xs)
        .accessibilityLabel("Select Results Event")
    }

    private func contentChip(for content: ResultsDetailContent) -> some View {
        let isSelected = selectedContent == content

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selectedContent = content
            }
        } label: {
            Text(content.title)
                .font(.appCaptionStrong)
                .foregroundColor(isSelected ? .white : .appPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpace.sm)
                .padding(.horizontal, AppSpace.lg)
                .background {
                    ZStack {
                        if isSelected {
                            Capsule(style: .continuous)
                                .fill(Color.rdGreen)
                                .matchedGeometryEffect(id: "selectedContentChip", in: eventChipNamespace)
                        } else {
                            Capsule(style: .continuous)
                                .fill(Color.appBg)
                        }
                    }
                }
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            isSelected ? Color.white.opacity(0.18) : Color.appTertiary.opacity(0.18),
                            lineWidth: AppStroke.hairline
                        )
                )
                .shadow(
                    color: isSelected ? Color.rdGreen.opacity(0.16) : Color.clear,
                    radius: isSelected ? 5 : 0,
                    x: 0,
                    y: isSelected ? 2 : 0
                )
                .scaleEffect(isSelected ? 1.005 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func eventChip(for event: Events.CodingKeys) -> some View {
        let isSelected = selectedEvent == event

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selectedEvent = event
            }
        } label: {
            Text(event.title)
                .font(.appCaptionStrong)
                .foregroundColor(isSelected ? .white : .appPrimary)
                .lineLimit(1)
                .padding(.vertical, AppSpace.sm)
                .padding(.horizontal, AppSpace.lg)
                .background {
                    ZStack {
                        if isSelected {
                            Capsule(style: .continuous)
                                .fill(Color.rdGreen)
                                .matchedGeometryEffect(id: "selectedEventChip", in: eventChipNamespace)
                        } else {
                            Capsule(style: .continuous)
                                .fill(Color.appBg)
                        }
                    }
                }
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            isSelected ? Color.white.opacity(0.18) : Color.appTertiary.opacity(0.18),
                            lineWidth: AppStroke.hairline
                        )
                )
                .shadow(
                    color: isSelected ? Color.rdGreen.opacity(0.16) : Color.clear,
                    radius: isSelected ? 5 : 0,
                    x: 0,
                    y: isSelected ? 2 : 0
                )
                .scaleEffect(isSelected ? 1.005 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var daysheetsSection: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text("Daysheets")
                .font(.appCardTitle)
                .foregroundColor(.appPrimary)

            if daysheetsLoading {
                ProgressView("Loading daysheets...")
            } else if let daysheetsError {
                Text(daysheetsError)
                    .font(.appBody)
                    .foregroundColor(.red)
            } else if daysheets.isEmpty {
                Text("No daysheets returned yet for this rodeo.")
                    .font(.appBody)
                    .foregroundColor(.appTertiary)
            } else {
                VStack(spacing: AppSpace.sm) {
                    ForEach(daysheets) { daysheet in
                        NavigationLink {
                            DaysheetDetailView(
                                rodeoName: rodeoName,
                                daysheet: daysheet,
                                preferredEvent: selectedEvent
                            )
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(daysheet.roundsDisplay)
                                        .font(.appBodyStrong)
                                        .foregroundColor(.appPrimary)
                                        .multilineTextAlignment(.leading)
                                    Text(daysheet.startDisplay)
                                        .font(.appCaptionStrong)
                                        .foregroundColor(.appTertiary)
                                    Text("\(daysheet.eventNames.count) events")
                                        .font(.appCaption)
                                        .foregroundColor(.appSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.appSecondary)
                            }
                            .padding(AppSpace.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .fill(Color.appBg)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .appCardStyle()
    }
    
    var roundsList: some View {
        let roundCount = resultsApi.results.rounds.count
        
        return VStack(spacing: AppSpace.md) {
            if !topMoneyEarners.isEmpty {
                topMoneyEarnersCard
            }

            ForEach(resultsApi.results.rounds, id: \.id) { round in
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(round.roundDisplay(roundCount: roundCount))
                            .foregroundColor(.appSecondary)
                            .font(.appRowTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(selectedEvent == .tr ? "Time" : "Result")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        
                        Text("Earnings")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                            .frame(width: 80, alignment: .trailing)
                    }
                    
                    if selectedEvent == .tr {
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
                
                BannerAd(placement: .resultsDetailSection)
            }
        }
    }

    private var topMoneyEarners: [MoneyEarner] {
        var earnersByContestant = [Int: MoneyEarner]()

        resultsApi.results.rounds
            .flatMap(\.winners)
            .filter { $0.payoff > 0 }
            .forEach { winner in
                if let currentEarner = earnersByContestant[winner.contestantId] {
                    earnersByContestant[winner.contestantId] = currentEarner.adding(payoff: winner.payoff)
                } else {
                    earnersByContestant[winner.contestantId] = MoneyEarner(
                        contestantId: winner.contestantId,
                        name: winner.name,
                        hometown: winner.hometownDisplay,
                        imageUrl: winner.imageUrl,
                        payoff: winner.payoff
                    )
                }
            }

        return earnersByContestant.values
            .sorted {
                if $0.payoff == $1.payoff {
                    return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                }

                return $0.payoff > $1.payoff
            }
            .prefix(10)
            .map { $0 }
    }

    private var topMoneyEarnersCard: some View {
        let earners = topMoneyEarners

        return VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("Top Money Earners")
                    .foregroundColor(.appSecondary)
                    .font(.appRowTitle)
                    .fontWeight(.bold)

                Spacer()

                Text("Earnings")
                    .font(.appMetricLabel)
                    .foregroundColor(.appTertiary)
                    .frame(width: 96, alignment: .trailing)
            }

            ForEach(earners) { earner in
                moneyEarnerRow(earner)

                if earner.id != earners.last?.id {
                    Divider()
                        .overlay(Color.appTertiary.opacity(0.25))
                }
            }
        }
        .appCardStyle()
    }

    private func moneyEarnerRow(_ earner: MoneyEarner) -> some View {
        HStack(alignment: .center, spacing: AppSpace.xs) {
            earner.image
                .scaleEffect(0.95)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                NavigationLink {
                    BioView(athleteId: earner.contestantId)
                } label: {
                    HStack(spacing: AppSpace.xxs) {
                        Text(earner.name)
                            .foregroundColor(.appPrimary)
                            .font(.appBodyStrong)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .multilineTextAlignment(.leading)
                            .layoutPriority(2)

                        favoriteIcon(for: earner.contestantId)
                    }
                }
                .buttonStyle(.plain)

                Text(earner.hometown)
                    .foregroundColor(.appTertiary)
                    .font(.appCaption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .allowsTightening(true)
                    .layoutPriority(1)
            }
            .layoutPriority(1)

            Spacer()

            Text(earner.earnings)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.appPrimary)
                .monospacedDigit()
                .frame(width: 96, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .contextMenu {
            favoriteMenuButton(
                athleteId: earner.contestantId,
                name: earner.name,
                event: selectedEvent.rawValue
            )
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
                    HStack(spacing: AppSpace.xxs) {
                        Text(winner.name)
                            .foregroundColor(.appPrimary)
                            .font(.appBodyStrong)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .multilineTextAlignment(.leading)
                            .layoutPriority(2)

                        favoriteIcon(for: winner.contestantId)
                    }
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
        .contextMenu {
            favoriteMenuButton(
                athleteId: winner.contestantId,
                name: winner.name,
                event: selectedEvent.rawValue
            )
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
                        Text("Header")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        
                        NavigationLink {
                            BioView(athleteId: team.headerId)
                        } label: {
                            HStack(spacing: AppSpace.xxs) {
                                Text(team.headerName)
                                    .foregroundColor(.appPrimary)
                                    .font(.appBody)
                                    .fontWeight(.bold)
                                    .lineLimit(1)

                                favoriteIcon(for: team.headerId)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack(spacing: AppSpace.xs) {
                    team.heelerImage
                        .scaleEffect(0.9)
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: AppSpace.xxs) {
                        Text("Heeler")
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        
                        NavigationLink {
                            BioView(athleteId: team.heelerId)
                        } label: {
                            HStack(spacing: AppSpace.xxs) {
                                Text(team.heelerName)
                                    .foregroundColor(.appPrimary)
                                    .font(.appBody)
                                    .fontWeight(.bold)
                                    .lineLimit(1)

                                favoriteIcon(for: team.heelerId)
                            }
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
        .contextMenu {
            favoriteMenuButton(
                athleteId: team.headerId,
                name: team.headerName,
                event: selectedEvent.rawValue,
                label: NSLocalizedString("Add Header to Favorites", comment: "")
            )

            favoriteMenuButton(
                athleteId: team.heelerId,
                name: team.heelerName,
                event: selectedEvent.rawValue,
                label: NSLocalizedString("Add Heeler to Favorites", comment: "")
            )
        }
    }

    @ViewBuilder
    private func favoriteIcon(for athleteId: Int) -> some View {
        if isFavorite(athleteId: athleteId) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.appSecondary)
                .accessibilityLabel("Favorite")
        }
    }

    @ViewBuilder
    private func favoriteMenuButton(
        athleteId: Int,
        name: String,
        event: String,
        label: String = NSLocalizedString("Add to Favorites", comment: "")
    ) -> some View {
        if isFavorite(athleteId: athleteId) {
            Label(NSLocalizedString("Favorite", comment: ""), systemImage: "star.fill")
        } else {
            Button {
                addFavoriteAthlete(athleteId: athleteId, name: name, event: event)
            } label: {
                Label(label, systemImage: "star.badge.plus")
            }
        }
    }

    private func isFavorite(athleteId: Int) -> Bool {
        widgetAthletes.contains { $0.athleteId == athleteId }
    }

    private var nextAthleteSortOrder: Int {
        max((widgetAthletes.compactMap(\.sortOrder).max() ?? -1) + 1, widgetAthletes.count)
    }

    private func addFavoriteAthlete(athleteId: Int, name: String, event: String) {
        guard !isFavorite(athleteId: athleteId) else { return }

        let widgetEvent = StandingsEvent(rawValue: event)?.withTeamRopingConversion ?? event
        let athlete = WidgetAthlete(
            athleteId: athleteId,
            name: name,
            event: widgetEvent,
            events: [widgetEvent],
            sortOrder: nextAthleteSortOrder
        )

        modelContext.insert(athlete)

        do {
            try modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            FavoriteAlert.added(name).present
        } catch {
            modelContext.delete(athlete)
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
            eventTitle: selectedEvent.title,
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

    private func loadDaysheetsIfNeeded() async {
        guard hasDaysheets, daysheets.isEmpty, !daysheetsLoading else { return }
        daysheetsLoading = true
        defer { daysheetsLoading = false }

        do {
            let url = ApiUrls().rodeoDaysheetsUrl(for: rodeoId)
            let response = try await APIClient.fetch(DaysheetResponse.self, from: url)
            daysheets = makeDaysheets(from: response)
            daysheetsError = nil
        } catch {
            daysheetsError = "Unable to load daysheets right now."
        }
    }

    private func makeDaysheets(from response: DaysheetResponse) -> [ScheduleDaysheet] {
        let merged = response.data.map { startDateKey, performances in
            ScheduleDaysheet(startDateKey: startDateKey, performances: performances)
        }

        return merged.sorted { lhs, rhs in
            if lhs.sortDate == rhs.sortDate {
                return lhs.rounds.count < rhs.rounds.count
            }
            return lhs.sortDate < rhs.sortDate
        }
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

private struct MoneyEarner: Identifiable {
    let contestantId: Int
    let name: String
    let hometown: String
    let imageUrl: String?
    let payoff: Double

    var id: Int { contestantId }

    var earnings: String {
        payoff.currencyABS
    }

    var image: some View {
        AthleteImageView(preferredImageUrl: imageUrl)
    }

    func adding(payoff additionalPayoff: Double) -> MoneyEarner {
        MoneyEarner(
            contestantId: contestantId,
            name: name,
            hometown: hometown,
            imageUrl: imageUrl,
            payoff: payoff + additionalPayoff
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
