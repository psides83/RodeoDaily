//
//  RodeoDailyWidget.swift
//  RodeoDailyWidget
//
//  Created by Payton Sides on 2/3/23.
//

import WidgetKit
import SwiftUI

struct StandingsWidgetLargeView : View {
    var entry: StandingsProvider.Entry
        
    var body: some View {
        let standings = entry.standings
        
        VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text(entry.configuration.event.title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            ForEach(standings ?? [], id: \.earnings) { position in
                
                Divider()
                    .overlay(Color.appSecondary)
                    .environment(\.colorScheme, .dark)
                
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.system(size: 18, weight: .semibold))
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(position.hometown ?? "")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        
                    }
            }
            
            HStack {
                Spacer()
                
                Text(NSLocalizedString("Updated ", comment: "") + entry.date.medium)
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
        .containerBackground(for: .widget) {
            Color.rdGreen
        }
        .environment(\.colorScheme, .dark)
    }
}

struct RodeoDailyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let data = WidgetSampleData().standingsSampleData
        
        Group {
            StandingsWidgetLargeView(entry: StandingsWidgetEntry(date: Date(), configuration: StandingsWidgetIntent(), standings: data, position: nil))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
