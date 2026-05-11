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
            .filter { $0.eventType == entry.event }
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
    
    func currentYearEarnings(for event: String) -> String {
        return entry.bio.career.filter({ $0.season == Date().yearInt && $0.eventType == event })[0].earnings.currencyABS
    }
    
    func currentYearRank(for event: String) -> String {
        let rankData = entry.bio.rankings.filter({ $0.season == Date().yearInt && $0.eventName.localizedCaseInsensitiveContains(event.eventDisplay.localizedLowercase) })[0]
        
        return "\(rankData.rank) in \(rankData.eventName) with \(currentYearEarnings(for: event))"
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
    }

    private func parsedResultDate(_ value: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        if let date = formatter.date(from: value) {
            return date
        }

        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return fallback.date(from: value) ?? .distantPast
    }
}

struct FavoriteWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //            FavoriteWidgetLargeView(entry: FavoriteWidgetEntry(date: Date(), bio: exampleData, event: .td))
            //                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            FavoriteWidgetSmallView(entry: FavoriteWidgetEntry(date: Date(), bio: WidgetSampleData().favoriteSampleData, event: "TD"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
