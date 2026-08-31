//
//  FavoriteWidgetSmallView.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/16/24.
//

import SwiftUI
import WidgetKit

struct FavoriteWidgetSmallView : View {
    var entry: FavoriteProvider.Entry
    
    @Environment(\.sizeCategory) var deviceSize
    
    var latestResults: ArraySlice<BioResult> {
        entry.bio.results
            .filter { selectedBioEventTypes.contains($0.eventType) }
            .sorted { lhs, rhs in
                let leftDate = parsedResultDate(lhs.endDate)
                let rightDate = parsedResultDate(rhs.endDate)
                if leftDate == rightDate {
                    return lhs.rodeoResultId > rhs.rodeoResultId
                }
                return leftDate > rightDate
            }
            .prefix(1)
    }
    
    func currentYearEarnings(for event: String) -> String? {
        return entry.bio.career.first {
            $0.season == Date().yearInt && bioEventTypes(for: event).contains($0.eventType)
        }?.earnings.currencyABS
    }
    
    func currentYearRank(for event: String) -> String {
        let rankData = entry.bio.rankings.first { ranking in
            ranking.season == Date().yearInt
            &&
            rankingSearchTerms(for: event).contains { term in
                ranking.eventName.localizedCaseInsensitiveContains(term)
            }
        }

        guard let rankData else {
            return String(format: NSLocalizedString("Latest %@ results", comment: ""), event.eventDisplay)
        }
        
        if let earnings = currentYearEarnings(for: event) {
            return "\(rankData.rank) in \(rankData.eventName) with \(earnings)"
        }

        return "\(rankData.rank) in \(rankData.eventName)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text("Rodeo Daily")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            
            HStack(alignment: .center) {
                Text(entry.bio.name)
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .semibold))
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Divider()
                .overlay(Color.appSecondary)
                .environment(\.colorScheme, .dark)
            
            ForEach(entry.bio.currentSeasonRankings().prefix(2)) { ranking in
                VStack(alignment: .leading, spacing: 2) {
                    Text(ranking.eventName)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 2) {
                        Text(ranking.ranking)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                        
                        Text("with")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                        
                        Text(ranking.earnings.currencyABS)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.rdGreen
        }
        .environment(\.colorScheme, .light)
        .widgetURL(entry.athleteBioURL)
    }

    private func parsedResultDate(_ value: String) -> Date {
        value.rodeoDate ?? .distantPast
    }

    private var selectedBioEventTypes: Set<String> {
        bioEventTypes(for: entry.event)
    }

    private func bioEventTypes(for event: String) -> Set<String> {
        switch event {
        case "TR", "TRHD", "TRHL":
            return ["TR", "TRHD", "TRHL"]
        default:
            return [event]
        }
    }

    private func rankingSearchTerms(for event: String) -> [String] {
        switch event {
        case "TR":
            return ["Team Roping"]
        case "TRHD":
            return ["Team Roping (Headers)", "Team Roping"]
        case "TRHL":
            return ["Team Roping (Heelers)", "Team Roping"]
        default:
            return [event.eventDisplay]
        }
    }
}

struct FavoriteWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //            FavoriteWidgetLargeView(entry: FavoriteWidgetEntry(date: Date(), bio: exampleData, event: .td))
            //                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            FavoriteWidgetSmallView(entry: FavoriteWidgetEntry(date: Date(), bio: WidgetSampleData().favoriteSampleData, event: "TD", athleteId: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
