//
//  FavoriteWidgetView.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import SwiftUI
import WidgetKit

struct FavoriteWidgetLargeView : View {
    var entry: FavoriteProvider.Entry
    
    //    @Environment(\.widgetFamily) var widgetFamily
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
            .prefix(4)
    }
    
    var currentYearEarnings: String? {
        currentYearCareer?.earnings.currencyABS
    }
    
    var currentYearRank: String {
        if let rankData = currentYearRanking, let currentYearEarnings {
            return "\(rankData.rank) in \(rankData.eventName) with \(currentYearEarnings)"
        }

        if let rankData = currentYearRanking {
            return "\(rankData.rank) in \(rankData.eventName)"
        }

        if let currentYearEarnings {
            return "\(eventDisplay) with \(currentYearEarnings)"
        }
        
        return String(format: NSLocalizedString("Latest %@ results", comment: ""), eventDisplay)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text(entry.bio.name)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            Text(currentYearRank)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text("Latest Results")
                .foregroundColor(.appSecondary)
                .font(.system(size: 16, weight: .semibold))
                .environment(\.colorScheme, .dark)

            if latestResults.isEmpty {
                Text(String(format: NSLocalizedString("No recent results for %@.", comment: ""), eventDisplay))
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            ForEach(latestResults, id: \.rodeoResultId) { result in
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Divider()
                        .overlay(Color.appSecondary)
                        .environment(\.colorScheme, .dark)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Text(result.location)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                        
                        Text(result.endDate.medium)
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(result.roundDisplay)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 20) {
                        Text(result.placeDisplay)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .frame(width: 40, alignment: .leading)
                        
                        Spacer()
                        
                        Text(result.resultDisplay)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 40)
                        
                        Spacer()
                        
                        Text(result.payoutDisplay)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 100, alignment: .trailing)
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
        switch entry.event {
        case "TR", "TRHD", "TRHL":
            return ["TR", "TRHD", "TRHL"]
        default:
            return [entry.event]
        }
    }

    private var eventDisplay: String {
        let display = entry.event.eventDisplay
        return display.isEmpty ? entry.event : display
    }

    private var rankingSearchTerms: [String] {
        switch entry.event {
        case "TR":
            return ["Team Roping"]
        case "TRHD":
            return ["Team Roping (Headers)", "Team Roping"]
        case "TRHL":
            return ["Team Roping (Heelers)", "Team Roping"]
        default:
            return [eventDisplay]
        }
    }

    private var currentYearCareer: Career? {
        entry.bio.career.first {
            $0.season == Date().yearInt && selectedBioEventTypes.contains($0.eventType)
        }
    }

    private var currentYearRanking: Ranking? {
        entry.bio.rankings.first { ranking in
            ranking.season == Date().yearInt
            &&
            rankingSearchTerms.contains { term in
                ranking.eventName.localizedCaseInsensitiveContains(term)
            }
        }
    }
}

struct FavoriteWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            FavoriteWidgetLargeView(entry: FavoriteWidgetEntry(date: Date(), bio: WidgetSampleData().favoriteSampleData, event: "TD"))
//                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            
            FavoriteWidgetLargeView(entry: FavoriteWidgetEntry(date: Date(), bio: WidgetSampleData().favoriteSampleData, event: "TD", athleteId: nil))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
