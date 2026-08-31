//
//  RodeoDailyWatchWidgets.swift
//  RodeoDailyWatchWidgets
//
//  Created by Payton Sides on 2/20/23.
//

import WidgetKit
import SwiftUI

struct StandingsARWidgetView: View {
    var entry: StandingsProvider.Entry

    var body: some View {
        if let standingsPostion = entry.position {
            VStack(alignment: .leading) {
                Text(entry.configuration.event.localizedTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.leading, 6)
                    .padding(.bottom, -2)
                    .widgetAccentable()
                
                HStack(spacing: 6) {
                    Text(standingsPostion.place.string)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    VStack(alignment: .leading) {
                        Text(standingsPostion.name)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .layoutPriority(1)
                        
                        Text(standingsPostion.earnings.currencyABS)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appPrimary, lineWidth: 1.5).widgetAccentable())
            }
            .containerBackground(for: .widget) {
                Color.rdGreen
            }
            .preferredColorScheme(.dark)
        } else {
            ContentUnavailableView {
                Label("No Standings", systemImage: "list.number")
            } description: {
                Text("Standings data is unavailable")
            }
        }
    }
}

struct RodeoDailyWatchWidgets_Previews: PreviewProvider {
    static var previews: some View {
        let data = WidgetSampleData().standingsSampleData[0]
        
        StandingsARWidgetView(
            entry: StandingsWidgetEntry(
                date: Date(),
                configuration: StandingsWidgetIntent(),
                standings: nil,
                position: data
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
