//
//  AthleteCellView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/24/24.
//

import SwiftUI
import SwiftData

struct AthleteCellView: View {
    @Environment(\.modelContext) var modelContext
    
    @StateObject var viewModel = BioViewModel()
    
    let athlete: WidgetAthlete
    
    var body: some View {
        Group {
            if viewModel.loading {
                AthleteCellViewLoader()
            } else {
                VStack(alignment: .leading, spacing: AppSpace.md) {
                    HStack(alignment: .top, spacing: AppSpace.md) {
                        VStack(alignment: .leading, spacing: AppSpace.xs) {
                            Text(viewModel.bio.name)
                                .foregroundColor(.appPrimary)
                                .font(.appCardTitle)
                                .fontWeight(.bold)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(viewModel.seasonRanking())
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.appBody)
                                .foregroundColor(.appSecondary)
                            
                            Text(athlete.event.eventDisplay)
                                .font(.appCaptionStrong)
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, AppSpace.sm)
                                .padding(.vertical, AppSpace.xxs)
                                .background(
                                    Capsule()
                                        .fill(Color.appSecondary.opacity(0.18))
                                )
                        }
                        
                        Spacer()
                        
                        viewModel.bio.image
                            .frame(width: 92, height: 92)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpace.sm) {
                        HStack {
                            Text("Latest Results")
                                .foregroundColor(.appPrimary)
                                .font(.appBodyStrong)
                            
                            Spacer()
                            
                            HStack(spacing: AppSpace.md) {
                                Text("Result")
                                Text("Earnings")
                                    .frame(width: 92, alignment: .trailing)
                            }
                            .font(.appMetricLabel)
                            .foregroundColor(.appTertiary)
                        }
                        
                        ForEach(latestResults, id: \.rodeoResultId) { result in
                            Divider()
                                .overlay(Color.appTertiary.opacity(0.25))
                            
                            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                                Text(result.rodeoName)
                                    .font(.appBodyStrong)
                                    .foregroundColor(.appPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                                
                                HStack(alignment: .center, spacing: AppSpace.sm) {
                                    HStack(spacing: AppSpace.xs) {
                                        Text(result.location)
                                            .font(.appCaption)
                                            .foregroundColor(.appTertiary)
                                        
                                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                                        
                                        Text(result.endDate.medium)
                                            .font(.appCaption)
                                            .foregroundColor(.appTertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: AppSpace.md) {
                                        Text(result.resultDisplay)
                                            .foregroundColor(.appPrimary)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .monospacedDigit()
                                            .frame(width: 56, alignment: .trailing)
                                        
                                        Text(result.payoutDisplay)
                                            .foregroundColor(.appPrimary)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .monospacedDigit()
                                            .frame(width: 92, alignment: .trailing)
                                    }
                                    
                                    Text(result.placeDisplay)
                                        .foregroundColor(.appSecondary)
                                        .font(.appCaptionStrong)
                                        .frame(width: 38, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                .appCardStyle()
            }
        }
        .task {
            if athlete.athleteId != 0 {
                await viewModel.setSelectedEvent(athlete.event)
                await viewModel.getBio(for: athlete.athleteId)
                _ = viewModel.evaluateFollowAlerts(modelContext: modelContext)
            }
        }
    }
    
    var latestResults: [BioResult] {
        Array(
            viewModel.bio.results
                .filter({ $0.eventType == viewModel.selectedEvent })
                .sorted(by: { $0.endDate > $1.endDate })
                .prefix(3)
        )
    }
}

#Preview {
    AthleteCellView(athlete: WidgetAthlete(athleteId: 72983, name: "", event: "TR", events: ["TR"]))
}
