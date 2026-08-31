//
//  ResultsListView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct ResultsListView: View {
    @ObservedObject var viewModel: BioViewModel
    @State private var initialOffset: CGFloat?

    
    // MARK: - Body
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

                resultsHeader
                
                if viewModel.results.isEmpty {
                    ContentUnavailableView {
                        Label("No Results Found", systemImage: "list.number")
                            .foregroundColor(.appPrimary)
                    } description: {
                        Text("Try a different season, sort option, or search term.")
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.top, AppSpace.lg)
                } else {
                    columnHeader
                    
                    LazyVStack(spacing: AppSpace.md) {
                        if usesFlatResultList {
                            ForEach(flatResults, id: \.rodeoResultId) { result in
                                if let event = codingKey(from: result.eventType) {
                                    NavigationLink {
                                        SingleRodeoResults(
                                            rodeoId: result.rodeoId,
                                            rodeoName: result.rodeoName,
                                            location: result.location,
                                            endDate: result.endDate,
                                            event: event
                                        )
                                    } label: {
                                        flatResultCell(result)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    flatResultCell(result)
                                }
                            }
                        } else {
                            ForEach(groupedResults) { group in
                                if let event = codingKey(from: group.eventType) {
                                    NavigationLink {
                                        SingleRodeoResults(
                                            rodeoId: group.rodeoId,
                                            rodeoName: group.rodeoName,
                                            location: group.location,
                                            endDate: group.endDate,
                                            event: event
                                        )
                                    } label: {
                                        BioResultCellView(group: group)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    BioResultCellView(group: group)
                                }
                            }
                        }
                    }
                    
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
        }
    }
    
    private var resultsHeader: some View {
        VStack(alignment: .leading, spacing: AppSpace.xxs) {
            HStack(alignment: .center, spacing: AppSpace.sm) {
                Text("Results")
                    .font(.appSectionTitle)
                    .foregroundColor(.appPrimary)
                
                Spacer()

                searchButton
            }
            
            if viewModel.showSearchBar {
                searchField
                    .padding(.top, AppSpace.sm)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            HStack(spacing: AppSpace.sm) {
                Menu {
                    ForEach(BioResult.SortingKeyPath.allCases) { keyPath in
                        Button {
                            viewModel.sortResultsBy = keyPath
                        } label: {
                            Text(keyPath.title(for: viewModel.selectedEvent))
                        }
                    }
                } label: {
                    compactFilterChip(value: viewModel.sortResultsBy.title(for: viewModel.selectedEvent))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Menu {
                    ForEach(viewModel.bio.seasons, id: \.self) { season in
                        Button {
                            viewModel.selectedSeason = season
                        } label: {
                            Text(season)
                        }
                    }
                } label: {
                    compactFilterChip(value: viewModel.selectedSeason)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text("\(viewModel.selectedEvent?.eventDisplay ?? "") • \(viewModel.selectedSeason)")
                .font(.appBodyStrong)
                .foregroundColor(.appSecondary)
            
            Text(resultsSummaryText)
                .font(.appCaption)
                .foregroundColor(.appTertiary)
        }
        .appCardStyle()
    }
    
    private var searchButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.showSearchBar.toggle()
                if !viewModel.showSearchBar {
                    viewModel.searchText = ""
                }
            }
        } label: {
            Image(systemName: viewModel.showSearchBar ? "xmark.circle" : "magnifyingglass")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.appPrimary)
                .frame(width: 34, height: 34)
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
    }
    
    private var searchField: some View {
        HStack(spacing: AppSpace.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appSecondary)
            
            TextField("Search rodeo, location, or result", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpace.md)
        .padding(.vertical, AppSpace.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(Color.appBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
        )
    }
    
    private func compactFilterChip(value: String) -> some View {
        HStack(spacing: AppSpace.xs) {
            Text(value)
                .font(.appCaptionStrong)
                .foregroundColor(.appPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(.appSecondary)
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
    
    private var columnHeader: some View {
        var resultType = ""
        if viewModel.selectedEvent == "BR" || viewModel.selectedEvent == "SB" || viewModel.selectedEvent == "BB" {
            resultType = NSLocalizedString("Score", comment: "")
        } else { resultType = NSLocalizedString("Time", comment: "") }
        
        return HStack {
            Text("Round")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 68, alignment: .leading)
            
            Text("Place")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 54, alignment: .leading)
            
            Spacer()
            
            Text(resultType)
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 74, alignment: .trailing)
            
            Text("Earnings")
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .frame(width: 96, alignment: .trailing)
        }
        .padding(.horizontal, AppSpace.sm)
    }
    
    private var groupedResults: [BioRodeoResultGroup] {
        var grouped: [BioRodeoResultGroup] = []
        var indexByKey: [String: Int] = [:]
        
        for result in viewModel.results {
            let key = "\(result.rodeoId)-\(result.endDate)-\(result.eventType)"
            
            if let index = indexByKey[key] {
                grouped[index].results.append(result)
            } else {
                indexByKey[key] = grouped.count
                grouped.append(
                    BioRodeoResultGroup(
                        id: key,
                        rodeoId: result.rodeoId,
                        rodeoName: result.rodeoName,
                        location: result.location,
                        endDate: result.endDate,
                        eventType: result.eventType,
                        results: [result]
                    )
                )
            }
        }
        
        if viewModel.sortResultsBy == .rodeoEarnings {
            return grouped.sorted { lhs, rhs in
                if lhs.totalPayoff == rhs.totalPayoff {
                    if lhs.endDate == rhs.endDate {
                        return lhs.rodeoName > rhs.rodeoName
                    }

                    return lhs.endDate > rhs.endDate
                }

                return lhs.totalPayoff > rhs.totalPayoff
            }
        }

        return grouped
    }
    
    private var flatResults: [BioResult] {
        viewModel.results
    }
    
    private var usesFlatResultList: Bool {
        viewModel.sortResultsBy == .result || viewModel.sortResultsBy == .earnings
    }
    
    private var resultsSummaryText: String {
        if usesFlatResultList {
            return "\(viewModel.results.count) results"
        }
        
        return "\(groupedResults.count) rodeos • \(viewModel.results.count) results"
    }
    
    private func flatResultCell(_ result: BioResult) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(result.rodeoName)
                .font(.appBodyStrong)
                .foregroundColor(.appPrimary)
                .lineLimit(2)
            
            HStack(spacing: AppSpace.xs) {
                Text(result.location)
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
                
                Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                
                Text(result.endDate.medium)
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
            }
            
            HStack(spacing: AppSpace.sm) {
                Text(result.roundDisplay)
                    .font(.appCaptionStrong)
                    .foregroundColor(.appSecondary)
                    .frame(width: 68, alignment: .leading)
                
                Text(result.placeDisplay)
                    .font(.appRank)
                    .foregroundColor(.appSecondary)
                    .frame(width: 54, alignment: .leading)
                
                Spacer()
                
                Text(result.resultDisplay)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.appPrimary)
                    .monospacedDigit()
                    .frame(width: 74, alignment: .trailing)
                
                Text(result.payoutDisplay)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.appPrimary)
                    .monospacedDigit()
                    .frame(width: 96, alignment: .trailing)
            }
        }
        .appCardStyle()
    }
    
    func codingKey(from eventType: String) -> Events.CodingKeys? {
        let normalized = eventType.uppercased()
        
        if normalized == "TRHD" || normalized == "TRHL" {
            return .tr
        }
        
        return Events.CodingKeys(rawValue: normalized)
    }
}

struct ResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BioView(athleteId: 59836)
                .tint(.appSecondary)
        }
    }
}
