//
//  HomePage.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI

struct HomePage: View {
        
    var body: some View {
        ScrollView {
            ForEach(StandingsEvent.allCases) { event in
                EventCard(event: event)
                    .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    HomePage()
}
    

struct EventCard: View {
    @StateObject var api = StandingsApi()
    
    var data: [Position] = WidgetSampleData().standingsSampleData
    
    var event: StandingsEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text(event.title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("rodeo-daily-iOS-icon-sm")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            ForEach(api.standings.prefix(5), id: \.earnings) { position in
                
                Divider()
                    .overlay(Color.appSecondary)
                    .environment(\.colorScheme, .dark)
                
                    cell(position: position)
            }
            
//            HStack {
//                Spacer()
//                
//                Text(NSLocalizedString("Updated ", comment: "") + entry.date.medium)
//                    .foregroundColor(.white)
//                    .font(.caption)
//            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 20, height: 300)
        .background(Color.rdGreen)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .task {
            await api.getStandings(for: event)
        }
    }
    
    func cell(position: Position) -> some View {
        HStack(spacing: 16) {
            Text(position.place.string)
                .font(.system(size: 18, weight: .semibold))
                .fontWeight(.medium)
                .foregroundColor(.appSecondary)
            
            VStack(alignment: .leading) {
                Text(position.name)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Text(position.hometownDisplay)
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            Text(position.earnings.currency)
                .foregroundColor(.white)
                .font(.system(size: 16))
            
        }
    }
}
