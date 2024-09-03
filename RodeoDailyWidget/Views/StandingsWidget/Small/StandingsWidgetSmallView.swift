//
//  StandingsWidgetSmallView.swift
//  RodeoDailyWidgetExtension
//
//  Created by Payton Sides on 9/2/24.
//

import SwiftUI
import WidgetKit

struct StandingsWidgetSmallView : View {
    var entry: StandingsProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
//    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvent = .aa
    
    var body: some View {
        let standings = entry.standings
        
        VStack(alignment: .leading, spacing: widgetFamily == .systemSmall ? 4 : 6) {
            
            HStack {
                Text(entry.configuration.event.title)
                    .font(.system(size: widgetFamily == .systemSmall ? 16 : 22, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: widgetFamily == .systemSmall ? 24 : 32, height: widgetFamily == .systemSmall ? 24 : 32)
            }
            
            ForEach(standings ?? [], id: \.earnings) { position in
                
                Divider()
                    .overlay(Color.appSecondary)
                
                switch widgetFamily {
                case .systemSmall:
                    HStack(spacing: 10) {
                        Text(position.place.string)
                            .font(.system(size: 16, weight: .semibold))
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(position.earnings.currency)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                case .systemMedium:
                    HStack(spacing: 16) {
                        Text(position.place.string)
                            .font(.system(size: 16, weight: .semibold))
                            .fontWeight(.semibold)
                            .foregroundColor(.appSecondary)
                        
                        Text(position.name)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                    }
                default:
                    HStack {
                        Text(position.place.string)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.appSecondary)
                        
                        Text(position.name)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                        
                        Text(position.earnings.currency)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.rdGreen
        }
        .environment(\.colorScheme, .dark)
    }
}

struct RodeoDailyWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        let data = Array(WidgetSampleData().standingsSampleData.prefix(3))
        
        Group {
            StandingsWidgetSmallView(
                entry: StandingsWidgetEntry(
                    date: Date(),
                    configuration: StandingsWidgetIntent(),
                    standings: data,
                    position: nil
                )
            )
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            StandingsWidgetSmallView(
                entry: StandingsWidgetEntry(
                    date: Date(),
                    configuration: StandingsWidgetIntent(),
                    standings: data,
                    position: nil
                )
            )
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
