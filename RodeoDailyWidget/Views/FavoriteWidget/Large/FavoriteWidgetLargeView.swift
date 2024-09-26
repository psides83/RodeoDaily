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
        return entry.bio.results.filter({ $0.eventType == entry.event }).sorted(by: { $0.endDate > $1.endDate }).prefix(4)
    }
    
    var currentYearEarnings: String {
        return entry.bio.career.filter({ $0.season == Date().yearInt && $0.eventType == entry.event })[0].earnings.currencyABS
    }
    
    var currentYearRank: String {
        let rankData = entry.bio.rankings.filter({ $0.season == Date().yearInt && $0.eventName.localizedCaseInsensitiveContains(entry.event.eventDisplay.localizedLowercase) })[0]
        
        return "\(rankData.rank) in \(rankData.eventName) with \(currentYearEarnings)"
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
    }
}

struct FavoriteWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            FavoriteWidgetLargeView(entry: FavoriteWidgetEntry(date: Date(), bio: WidgetSampleData().favoriteSampleData, event: "TD"))
//                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            
            FavoriteWidgetLargeView(entry: FavoriteWidgetEntry(date: Date(), bio: WidgetSampleData().favoriteSampleData, event: "TD"))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
