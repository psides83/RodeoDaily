//
//  BioStatsView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 11/3/25.
//

import SwiftUI

struct BioStatsView: View {
    @ObservedObject var viewModel: BioViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 120), alignment: .leading),
        GridItem(.adaptive(minimum: 120), alignment: .leading),
        GridItem(.adaptive(minimum: 120), alignment: .leading)
    ]
    
    
    // MARK: - Body
    var body: some View {
        ZStack {
            List(content: listSection)
                .listStyle(.insetGrouped)
                .padding(.top, 50)
            
            VStack {
                HStack(alignment: .center) {
                    Text("Career Stats")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPrimary)
                        .padding(6)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
                .frame(height: 50)
                .padding(.horizontal, 20)
                .background(
                    Color
                        .secondarySystemGroupedBackground
                        .shadow(radius: 2)
                )
                
                Spacer()
            }
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    
    // MARK: - View Methods
    func listSection() -> some View {
        Group {
            ForEach(viewModel.bio.seasons, id: \.self) { season in
                Section(
                    header: VStack(alignment: .trailing) {
                        Text(season)
                            .font(.title)
                            .fontWeight(.bold)
//                            .padding(.bottom, 2)
                        
                        HStack {
                            Text(viewModel.stats(season: season).seasonEarningsAndRank.rank.rankingDisplay)
                                .font(.title3)
                            
                            Spacer()
                            Text(viewModel.stats(season: season).seasonEarningsAndRank.earnings)
                                .font(.title3)
                        }
                    }
                ) {
                    seasonCard(season: season)
                    //                    .listRowBackground(Color.appBg)
                }
            }
            Section {
                BannerAd().frame(height: 300)
            }
        }
    }
    
    // MARK: - Computed Property Views
    func seasonCard(season: String) -> some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading) {
                Text(viewModel.scoreTypeText.scoreType)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                HStack {
                    Text(viewModel.stats(season: season).bestGo.rodeo)
                    Spacer()
                    Text(viewModel.stats(season: season).bestGo.result)
                }
                .font(.subheadline)
            }
            
            VStack(alignment: .leading) {
                Text("Highest Earning Single \(viewModel.scoreTypeText.action):")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                HStack {
                    Text(viewModel.stats(season: season).earningsGo.rodeo)
                    Spacer()
                    Text(viewModel.stats(season: season).earningsGo.result)
                    Spacer()
                    Text(viewModel.stats(season: season).earningsGo.payout)
                }
                .font(.subheadline)
            }
            
            VStack(alignment: .leading) {
                Text("Highest Single Rodeo Earnings:")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                HStack {
                    Text(viewModel.stats(season: season).earningRodeo.rodeo)
                    Spacer()
                    Text(viewModel.stats(season: season).earningRodeo.payout)
                }
                .font(.subheadline)
            }
            
//            if viewModel.bio.nfrQualified(for: season.int) {
                if let result = (viewModel.nfrBestGo(season: season.int)) {
                    HStack {
                        Text("NFR \(viewModel.scoreTypeText.scoreType):")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(result)
                            .font(.subheadline)
                    }
                }
                
                if let nfrEarnings = viewModel.nfrEarnings(for: season) {
                    HStack {
                        Text("NFR Earnings:")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(nfrEarnings)
                            .font(.subheadline)
                    }
                }
//            }
            
            VStack {
                Text("Monthly Earnings:")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Spacer()
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.monthlyEarnings(season: season), id: \.month) { month in
                            VStack(alignment: .leading) {
                                Text(month.month)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(month.total.currencyABS)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .frame(maxWidth: 360)
                    
                    Spacer()
                }
            }
            .padding() // padding inside the background
            .background(Color.appPrimary.opacity(0.2)) // subtle overall background
            .cornerRadius(8)
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
