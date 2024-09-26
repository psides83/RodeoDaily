//
//  AthleteCellView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/24/24.
//

import SwiftUI

struct AthleteCellView: View {
    @StateObject var viewModel = BioViewModel()
    
    let athlete: WidgetAthlete
    
    var body: some View {
        Group {
            if viewModel.loading {
                AthleteCellViewLoader()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center) {
                        Text(viewModel.bio.name)
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text(viewModel.seasonRanking())
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
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.rdGreen)
                        .shadow(radius: 4, x: 0, y: 4)
                }
            }
        }
        .task {
            print(athlete.athleteId)
            if athlete.athleteId != 0 {
                await viewModel.setSelectedEvent(athlete.event)
                await viewModel.getBio(for: athlete.athleteId)
            }
        }
    }
    
    var latestResults: ArraySlice<BioResult> {
        return viewModel.bio.results.filter({ $0.eventType == viewModel.selectedEvent }).sorted(by: { $0.endDate > $1.endDate }).prefix(4)
    }
    
    var currentYearEarnings: String {
        return viewModel.bio.career.filter({ $0.season == Date().yearInt && $0.eventType == viewModel.selectedEvent })[0].earnings.currencyABS
    }
    
//    var currentYearRank: String {
//        let rankData = viewModel.bio.rankings.filter({ $0.season == Date().yearInt && $0.eventName.localizedCaseInsensitiveContains(athlete.event.eventDisplay.localizedLowercase) })[0]
//        
//        return "\(rankData.rank) in \(rankData.eventName) with \(currentYearEarnings)"
//    }
}

#Preview {
    AthleteCellView(athlete: WidgetAthlete(athleteId: 72983, name: "", event: "TR", events: ["TR"]))
}
