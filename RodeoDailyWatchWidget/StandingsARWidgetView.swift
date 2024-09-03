//
//  RodeoDailyWatchWidgets.swift
//  RodeoDailyWatchWidgets
//
//  Created by Payton Sides on 2/20/23.
//

import WidgetKit
import SwiftUI

struct StandingsARWidgetView : View {
    var entry: StandingsProvider.Entry

    var body: some View {
        if let standingsPostion = entry.position {
            VStack(alignment: .leading) {
                Text(entry.configuration.event.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appSecondary)
                    .padding(.leading, 10)
                    .padding(.bottom, -4)
                    .widgetAccentable()
                
                HStack {
                    Text(standingsPostion.place.string)
                        .font(.system(size: 18, weight: .semibold))
                    
                    VStack(alignment: .leading) {
                        Text(standingsPostion.name)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(standingsPostion.earnings.currencyABS)
                            .font(.system(size: 14, weight: .medium))
                    }
                    
                    Spacer()
                }
                .padding(6)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appPrimary, lineWidth: 2).widgetAccentable())
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
