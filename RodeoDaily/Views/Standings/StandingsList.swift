//
//  StandingsList.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/8/22.
//

import SwiftUI
import UIKit

struct StandingsList: View {
    @Environment(\.colorScheme) private var colorScheme
    var widgetAthletes: [WidgetAthlete]
    var followedAthletes: [FollowedAthlete]
    let standings: [Position]
    var loading: Bool
    let selectedTab: Tabs
    let searchText: String
    
    @Binding var selectedYear: String
    @Binding var selectedEvent: StandingsEvent
    @Binding var standingType: StandingType
    @Binding var selectedCircuit: Circuit
    
    let adPlacement: Int = 10
    @State private var hasAttemptedLoad = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isShowingShareRangeOptions = false
    @State private var isShowingShareSheet = false
    @State private var shareItems: [Any] = []
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xxl) {
            standingsHeader
                .padding(.bottom, -20)
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 10)

            standingsFilters
                .opacity(1 - collapseProgress)
                .offset(y: -collapseProgress * 10)
            
            if loading || (standings.isEmpty && !hasAttemptedLoad) {
                StandingsLoader()
            } else if filteredStandings.count > 0 {
                standingsList
                
                BannerAd(style: .mediumRectangle)
            } else {
                noStandings
            }
        }
        .onAppear {
            if !standings.isEmpty {
                hasAttemptedLoad = true
            }
        }
        .onChange(of: loading) { _, isLoading in
            if !isLoading {
                hasAttemptedLoad = true
            }
        }
        .offset(coordinateSpcae: .named("HOME_TAB_SCROLL")) { value in
            scrollOffset = value
        }
        .overlay(alignment: .topLeading) {
            standingsCollapsedStickyHeader
                .padding(.top, AppSpace.xs)
                .opacity(collapseProgress)
                .scaleEffect(0.96 + (0.04 * collapseProgress), anchor: .top)
                .offset(y: (1 - collapseProgress) * -14)
            .offset(y: -scrollOffset)
        }
        .animation(.easeOut(duration: 0.2), value: collapseProgress)
        .confirmationDialog(
            NSLocalizedString("Share Standings", comment: ""),
            isPresented: $isShowingShareRangeOptions,
            titleVisibility: .visible
        ) {
            ForEach(availableShareRanges, id: \.self) { option in
                Button(option.title) {
                    prepareStandingsShare(for: option)
                }
            }
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) { }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            AppShareSheet(items: shareItems)
        }
    }

    private var standingsCollapsedStickyHeader: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(selectedEvent.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(selectedYear) \(standingType.title)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .opacity(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, AppSpace.lg)
        .padding(.vertical, AppSpace.xs)
        .padding(.horizontal, AppSpace.sm)
        .background {
            Capsule(style: .continuous)
                .stroke(.gray.opacity(0.25), lineWidth: 1.5)
                .background(
                    Capsule(style: .continuous)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.42) : Color.appBg.opacity(0.8))
                )
                .background(
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .compositingGroup()
        }
    }
    
    // MARK: - Computed View Properties
    var standingsList: some View {
        LazyVStack(spacing: AppSpace.lg) {
            ForEach(filteredStandings.indices, id: \.self) { index in
                let position = filteredStandings[index]
                
                if (index % adPlacement) == 0 && index != 0 {
                    BannerAd(style: .mediumRectangle)
                }
                
                if position.hasBio {
                    NavigationLink {
                        if selectedEvent.rawValue == "GB" || selectedEvent.rawValue == "LB" {
                            BioView(athleteId: position.id, preferredEvent: selectedEvent.rawValue)
                        } else {
                        BioView(athleteId: position.id)
                        }
                    } label: {
                        StandingsCell(
                            position: position,
                            widgetAthletes: widgetAthletes,
                            followedAthletes: followedAthletes
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    StandingsCell(
                        position: position,
                        widgetAthletes: widgetAthletes,
                        followedAthletes: followedAthletes
                    )
                }
            }
        }
    }
    
    var standingsHeader: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text("Standings")
                .foregroundColor(.appPrimary)
                .font(.appSectionTitle)
                .fontWeight(.bold)
            
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text(headerTitle)
                    .foregroundColor(.appSecondary)
                    .font(.appCardTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Spacer()
                
                Menu {
                    ForEach(years, id: \.self) { season in
                        Button(season) {
                            selectedYear = season
                        }
                    }
                } label: {
                    HStack(spacing: AppSpace.xs) {
                        Text(selectedYear)
                            .foregroundColor(.appPrimary)
                            .font(.appCardTitle)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.appSecondary)
                    }
                }

//                Button {
//                    isShowingShareRangeOptions = true
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                        .foregroundColor(.appSecondary)
//                        .font(.appCardTitle)
//                }
//                .buttonStyle(.plain)
//                .accessibilityLabel("Share standings")
            }
        }
        .appCardStyle()
    }
    
    var standingsFilters: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 150), spacing: AppSpace.sm, alignment: .leading)],
            alignment: .leading,
            spacing: AppSpace.sm
        ) {
            filterMenuChip(
                title: NSLocalizedString("Type", comment: ""),
                value: standingType.title
            ) {
                ForEach(StandingType.allCases, id: \.self) { type in
                    Button(type.title) {
                        withAnimation {
                            setType(type)
                        }
                    }
                }
            }
            
            if standingType.hasEvents {
                filterMenuChip(
                    title: NSLocalizedString("Event", comment: ""),
                    value: selectedEvent.title
                ) {
                    ForEach(StandingsEvent.allCases, id: \.self) { event in
                        Button(event.title) {
                            withAnimation {
                                setEvent(event)
                            }
                        }
                    }
                }
            }
            
            if standingType == .circuit {
                filterMenuChip(
                    title: NSLocalizedString("Circuit", comment: ""),
                    value: selectedCircuit.title
                ) {
                    ForEach(Circuit.allCases, id: \.self) { circuit in
                        Button(circuit.title) {
                            withAnimation {
                                setCircuit(circuit)
                            }
                        }
                    }
                }
            }
        }
    }

    private func filterMenuChip<Content: View>(
        title: String,
        value: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Menu(content: content) {
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(title.uppercased())
                    .font(.appMetricLabel)
                    .foregroundColor(.appTertiary)
                
                HStack(spacing: AppSpace.xs) {
                    Text(value)
                        .font(.appBodyStrong)
                        .foregroundColor(.appPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.appSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppSpace.sm)
            .padding(.horizontal, AppSpace.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(Color.appBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
            )
        }
    }
    
    var headerTitle: String {
        if standingType == .circuit {
            return "\(selectedCircuit.title) \(standingType.title)"
        }
        
        if standingType.isNotSingleEvent {
            return "\(selectedEvent.title) \(standingType.title)"
        }
        
        return standingType.title
    }

    private var collapseProgress: CGFloat {
        let y = -scrollOffset
        let start: CGFloat = 30
        let distance: CGFloat = 70
        let progress = (y - start) / distance
        return min(max(progress, 0), 1)
    }

    var noStandings: some View {
        ContentUnavailableView {
            Label("Standings Could Not Load", systemImage: "list.number")
                .foregroundColor(.appPrimary)
        } description: {
            Text("We were not able to load these standings at this time. Try again later")
                .foregroundColor(.appPrimary)
        }
    }
    
    // MARK: - Computed Properties
    var filteredStandings: [Position] {
        standings.filter({
            searchText.isEmpty ? true : selectedTab == .standings
            &&
            $0.name.localizedCaseInsensitiveContains(searchText)
        })
    }
    
    var years: [String] {
        var lastYear: Int {
            if Date().monthInt >= 10 {
                return Date().yearInt + 2
            } else {
                return Date().yearInt + 1
            }
        }
        
        var array: [String] = []
        
        for year in 2009..<lastYear {
            array.append(year.string)
        }
        
        return array.sorted(by: { $0 > $1 })
    }
    
    func setType(_ type: StandingType) {
        standingType = type
    }
    
    func setEvent(_ event: StandingsEvent) {
        selectedEvent = event
    }
    
    func setCircuit(_ circuit: Circuit) {
        selectedCircuit = circuit
    }

    private var availableShareRanges: [ShareRangeOption] {
        let count = filteredStandings.count
        return ShareRangeOption.defaultRanges.filter { $0.count <= count }
    }

    private func prepareStandingsShare(for option: ShareRangeOption) {
        let rows = Array(filteredStandings.prefix(option.count))
        guard !rows.isEmpty else { return }

        let snapshot = StandingsShareCardView(
            title: headerTitle,
            subtitle: "\(selectedYear) • \(selectedEvent.title)",
            rows: rows,
            rangeTitle: option.title
        )

        guard let image = snapshot.snapshotImage() else { return }
        let link = URL(string: "https://rodeodaily.app") ?? URL(string: "https://apps.apple.com")!
        let message = "\(NSLocalizedString("Check out these standings on Rodeo Daily.", comment: ""))\n\(link.absoluteString)"
        shareItems = [image, message]
        isShowingShareSheet = true
    }
}

struct StandingsList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum ShareRangeOption: Hashable {
    case top3
    case top5
    case top10

    static let defaultRanges: [ShareRangeOption] = [.top3, .top5, .top10]

    var title: String {
        switch self {
        case .top3: return "Top 3"
        case .top5: return "Top 5"
        case .top10: return "Top 10"
        }
    }

    var count: Int {
        switch self {
        case .top3: return 3
        case .top5: return 5
        case .top10: return 10
        }
    }
}

struct AppShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct StandingsShareCardView: View {
    let title: String
    let subtitle: String
    let rows: [Position]
    let rangeTitle: String

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
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.appSecondary)
            Text(subtitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 10) {
                        Text(row.place.string)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.appSecondary)
                            .frame(width: 36, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.name)
                                .font(.title3.weight(.semibold))
                                .lineLimit(1)
                            Text(row.hometownDisplay)
                                .font(.title3.weight(.regular))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(row.earnings.currencyABS)
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(Color.appPrimary)
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
    func snapshotImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        return renderer.uiImage
    }
}
