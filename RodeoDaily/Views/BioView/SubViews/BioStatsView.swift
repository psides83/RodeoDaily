//
//  BioStatsView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 11/3/25.
//

import SwiftUI

struct BioStatsView: View {
    @ObservedObject var viewModel: BioViewModel
    @State private var initialOffset: CGFloat?
    @State private var selectedSeasonLocal: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                Color.clear
                    .frame(height: 0)
                    .offset(coordinateSpcae: .named("BIO_SCROLL_SHARED")) { value in
                        if initialOffset == nil {
                            initialOffset = value
                            viewModel.bioScrollOffset = 0
                            viewModel.bioPullDownOffset = 0
                            return
                        }
                        if !viewModel.bioHasUserScrolled {
                            viewModel.bioScrollOffset = 0
                            viewModel.bioPullDownOffset = 0
                            return
                        }
                        let baseline = initialOffset ?? value
                        let delta = value - baseline
                        let newScroll = max(-delta, 0)
                        viewModel.bioScrollOffset = newScroll < 1 ? 0 : newScroll
                        viewModel.bioPullDownOffset = 0
                    }

                Color.clear
                    .frame(height: BioTelegramHeaderView.expandedHeight - 12)

                statsHeader
                seasonChips

                if selectedSeasonStats == nil {
                    ContentUnavailableView {
                        Label(NSLocalizedString("No Stats Available", comment: ""), systemImage: "chart.bar.xaxis")
                    } description: {
                        Text(NSLocalizedString("No stats are available for this season and event.", comment: ""))
                    }
                    .padding(.top, AppSpace.lg)
                } else if let stats = selectedSeasonStats {
                    seasonOverviewCard(season: selectedSeason, stats: stats)
                    bestPerformanceCard(stats: stats)
                    nfrSummaryCard(season: selectedSeason)
                    monthlyEarningsCard(season: selectedSeason)
                    BannerAd(style: .mediumRectangle)
                }
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .simultaneousGesture(DragGesture(minimumDistance: 1)
            .onChanged { _ in
                viewModel.bioHasUserScrolled = true
            }
        )
        .onAppear {
            initialOffset = nil
            syncSelectedSeason()
        }
        .onChange(of: viewModel.bio.seasons) { _, _ in
            syncSelectedSeason()
        }
        .onChange(of: viewModel.selectedSeason) { _, newValue in
            guard !newValue.isEmpty, newValue != selectedSeasonLocal else { return }
            selectedSeasonLocal = newValue
        }
    }

    private var seasons: [String] {
        viewModel.bio.seasons
    }

    private var selectedSeason: String {
        if seasons.contains(selectedSeasonLocal) {
            return selectedSeasonLocal
        }

        if seasons.contains(viewModel.selectedSeason) {
            return viewModel.selectedSeason
        }

        return seasons.first ?? selectedSeasonLocal
    }

    private var selectedSeasonStats: (
        seasonEarningsAndRank: (rank: String, earnings: String),
        bestGo: (rodeo: String, result: String),
        earningsGo: (rodeo: String, result: String, payout: String),
        earningRodeo: (rodeo: String, payout: String)
    )? {
        guard !selectedSeason.isEmpty else { return nil }
        return viewModel.stats(season: selectedSeason)
    }

    private var statsHeader: some View {
        VStack(alignment: .leading, spacing: AppSpace.xxs) {
            HStack(alignment: .firstTextBaseline) {
                Text(NSLocalizedString("Career Stats", comment: ""))
                    .font(.appSectionTitle)
                    .foregroundColor(.appPrimary)

                Spacer()

                if hasBiographyContent {
                    NavigationLink {
                        BioDetailView(
                            athleteName: viewModel.bio.name,
                            biographyText: viewModel.bio.biographyText
                        )
                    } label: {
                        HStack {
                            Text(NSLocalizedString("Bio", comment: ""))
                                .font(.appBodyStrong)
                                .foregroundColor(.appSecondary)

                            Image(systemName: "chevron.right")
                                .font(.appBodyStrong)
                                .foregroundColor(.appSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(viewModel.selectedEvent?.eventDisplay ?? "")
                .font(.appBodyStrong)
                .foregroundColor(.appSecondary)
        }
        .appCardStyle()
    }

    private var hasBiographyContent: Bool {
        let html = viewModel.bio.biographyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !html.isEmpty else { return false }
        let plainText = html
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
        return plainText
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false
    }

    private var seasonChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpace.sm) {
                ForEach(seasons, id: \.self) { season in
                    Button {
                        withAnimation {
                            selectedSeasonLocal = season
                            viewModel.selectedSeason = season
                        }
                    } label: {
                        Text(season)
                            .font(.appBodyStrong)
                            .foregroundColor(selectedSeason == season ? .white : .appPrimary)
                            .padding(.horizontal, AppSpace.lg)
                            .padding(.vertical, AppSpace.sm)
                            .background(
                                Capsule()
                                    .fill(selectedSeason == season ? Color.rdGreen : Color.appBg)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func seasonOverviewCard(
        season: String,
        stats: (
            seasonEarningsAndRank: (rank: String, earnings: String),
            bestGo: (rodeo: String, result: String),
            earningsGo: (rodeo: String, result: String, payout: String),
            earningRodeo: (rodeo: String, payout: String)
        )
    ) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(String(format: NSLocalizedString("Season %@", comment: ""), season))
                    .font(.appMetricLabel)
                    .foregroundColor(.appTertiary)
                Text(stats.seasonEarningsAndRank.rank.rankingDisplay)
                    .font(.appCardTitle)
                    .foregroundColor(.appPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpace.xxs) {
                Text(NSLocalizedString("Earnings", comment: ""))
                    .font(.appMetricLabel)
                    .foregroundColor(.appTertiary)
                Text(stats.seasonEarningsAndRank.earnings)
                    .font(.appCardTitle)
                    .foregroundColor(.appSecondary)
            }
        }
        .appCardStyle()
    }

    private func bestPerformanceCard(
        stats: (
            seasonEarningsAndRank: (rank: String, earnings: String),
            bestGo: (rodeo: String, result: String),
            earningsGo: (rodeo: String, result: String, payout: String),
            earningRodeo: (rodeo: String, payout: String)
        )
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            Text(NSLocalizedString("Best Performances", comment: ""))
                .font(.appBodyStrong)
                .foregroundColor(.appPrimary)

            statRow(
                title: viewModel.scoreTypeText.scoreType.replacingOccurrences(of: ":", with: ""),
                rodeo: stats.bestGo.rodeo,
                trailing: stats.bestGo.result
            )

            statRow(
                title: String(format: NSLocalizedString("Best Paying %@", comment: ""), viewModel.scoreTypeText.action),
                rodeo: stats.earningsGo.rodeo,
                trailing: "\(stats.earningsGo.result) • \(stats.earningsGo.payout)"
            )

            statRow(
                title: NSLocalizedString("Best Paying Rodeo", comment: ""),
                rodeo: stats.earningRodeo.rodeo,
                trailing: stats.earningRodeo.payout
            )
        }
        .appCardStyle()
    }

    private func statRow(title: String, rodeo: String, trailing: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.xxs) {
            Text(title)
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)

            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text(rodeo)
                    .font(.appBody)
                    .foregroundColor(.appPrimary)
                    .lineLimit(2)

                Spacer()

                Text(trailing)
                    .font(.appBodyStrong)
                    .foregroundColor(.appSecondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func nfrSummaryCard(season: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(NSLocalizedString("NFR Summary", comment: ""))
                .font(.appBodyStrong)
                .foregroundColor(.appPrimary)

            if let result = viewModel.nfrBestGo(season: season.int) {
                HStack {
                    Text(String(format: NSLocalizedString("Best NFR %@", comment: ""), viewModel.scoreTypeText.scoreType.replacingOccurrences(of: ":", with: "")))
                        .font(.appBody)
                        .foregroundColor(.appPrimary)
                    Spacer()
                    Text(result)
                        .font(.appBodyStrong)
                        .foregroundColor(.appSecondary)
                }
            }

            if let nfrEarnings = viewModel.nfrEarnings(for: season) {
                HStack {
                    Text(NSLocalizedString("NFR Earnings", comment: ""))
                        .font(.appBody)
                        .foregroundColor(.appPrimary)
                    Spacer()
                    Text(nfrEarnings)
                        .font(.appBodyStrong)
                        .foregroundColor(.appSecondary)
                }
            }

            if viewModel.nfrBestGo(season: season.int) == nil && viewModel.nfrEarnings(for: season) == nil {
                Text(NSLocalizedString("No NFR stats for this season.", comment: ""))
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
            }
        }
        .appCardStyle()
    }

    private func monthlyEarningsCard(season: String) -> some View {
        let data = viewModel.monthlyEarnings(season: season)
        let maxTotal = max(data.map(\.total).max() ?? 0, 1)
        let regularSeasonTotal = data.reduce(0) { $0 + $1.total }

        return VStack(alignment: .leading, spacing: AppSpace.md) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text(NSLocalizedString("Monthly Earnings", comment: ""))
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)

                Spacer()

                Text("\(NSLocalizedString("Regular Season", comment: "")): \(regularSeasonTotal.currencyABS)")
                    .font(.appCaptionStrong)
                    .foregroundColor(.appSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            VStack(spacing: AppSpace.sm) {
                ForEach(data, id: \.month) { month in
                    HStack(spacing: AppSpace.sm) {
                        Text(month.month)
                            .font(.appCaptionStrong)
                            .foregroundColor(.appTertiary)
                            .frame(width: 34, alignment: .leading)

                        GeometryReader { proxy in
                            let width = max(0, proxy.size.width * CGFloat(month.total / maxTotal))

                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.appTertiary.opacity(0.15))

                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.appSecondary.opacity(month.total > 0 ? 0.9 : 0.3))
                                    .frame(width: width)
                            }
                        }
                        .frame(height: 16)

                        Text(month.total.currencyABS)
                            .font(.appCaptionStrong)
                            .foregroundColor(.appPrimary)
                            .frame(width: 86, alignment: .trailing)
                    }
                    .frame(height: 16)
                }
            }
        }
        .appCardStyle()
    }

    private func syncSelectedSeason() {
        guard !seasons.isEmpty else { return }
        let preferred = seasons.contains(viewModel.selectedSeason) ? viewModel.selectedSeason : (seasons.first ?? "")
        guard !preferred.isEmpty else { return }
        selectedSeasonLocal = preferred
        if viewModel.selectedSeason != preferred {
            viewModel.selectedSeason = preferred
        }
    }
}

struct BioStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BioView(athleteId: 59836)
                .tint(.appSecondary)
        }
    }
}
