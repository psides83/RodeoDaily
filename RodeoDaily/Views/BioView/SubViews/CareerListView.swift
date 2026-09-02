//
//  CareerListView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct CareerListView: View {
    @ObservedObject var viewModel: BioViewModel
    @State private var initialOffset: CGFloat?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                Color.clear
                    .frame(height: 0)
                    .offset(coordinateSpcae: .named("BIO_SCROLL_SHARED")) { value in
                        if initialOffset == nil {
                            initialOffset = value
                            viewModel.setBioHeaderOffsets(scrollOffset: 0, pullDownOffset: 0)
                            return
                        }
                        if !viewModel.bioHasUserScrolled {
                            viewModel.setBioHeaderOffsets(scrollOffset: 0, pullDownOffset: 0)
                            return
                        }
                        let baseline = initialOffset ?? value
                        let delta = value - baseline
                        let newScroll = max(-delta, 0)
                        viewModel.setBioHeaderOffsets(scrollOffset: newScroll, pullDownOffset: 0)
                    }

                Color.clear
                    .frame(height: BioTelegramHeaderView.expandedHeight - 12)

                headerCard
                columnHeader
                
                if viewModel.careerSeasons.isEmpty {
                    ContentUnavailableView {
                        Label("No Career Data", systemImage: "chart.line.text.clipboard")
                            .foregroundColor(.appPrimary)
                    } description: {
                        Text("No career rankings are available for this event.")
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.top, AppSpace.lg)
                } else {
                    LazyVStack(spacing: AppSpace.md) {
                        ForEach(Array(viewModel.careerSeasons.enumerated()), id: \.element.season) { index, season in
                            if AdPlacementPolicy.shouldShowListAd(beforeItemAt: index) {
                                BannerAd(placement: .athleteBioSection)
                            }

                            seasonCard(season)
                        }
                    }
                    
                    BannerAd(placement: .athleteBioSection)
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
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.xxs) {
            Text("Career")
                .font(.appSectionTitle)
                .foregroundColor(.appPrimary)
            
            Text(viewModel.selectedEvent?.eventDisplay ?? "")
                .font(.appBodyStrong)
                .foregroundColor(.appSecondary)
            
            Text("\(viewModel.careerSeasons.count) seasons")
                .font(.appCaption)
                .foregroundColor(.appTertiary)
        }
        .appCardStyle()
    }
    
    private var columnHeader: some View {
        HStack {
            Text("Season")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 68, alignment: .leading)
            
            Spacer()
            
            Text("Rank")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 72, alignment: .trailing)
            
            Text("Earnings")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 110, alignment: .trailing)
        }
        .padding(.horizontal, AppSpace.sm)
    }
    
    private func seasonCard(_ season: CareerWithEarinings) -> some View {
        HStack {
            Text(season.season)
                .font(.appBodyStrong)
                .foregroundColor(.appPrimary)
                .frame(width: 68, alignment: .leading)
            
            Spacer()
            
            Text(season.rank.rankingDisplay)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.appSecondary)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
            
            Text(season.earnings)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.appPrimary)
                .monospacedDigit()
                .frame(width: 110, alignment: .trailing)
        }
        .appCardStyle()
    }
}

struct CareerListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BioView(athleteId: 59836)
                .tint(.appSecondary)
        }
    }
}
