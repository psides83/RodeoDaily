//
//  BioResultCell.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/13/23.
//

import SwiftUI

struct BioRodeoResultGroup: Identifiable {
    let id: String
    let rodeoId: Int
    let rodeoName: String
    let location: String
    let endDate: String
    let eventType: String
    var results: [BioResult]
}

struct BioResultCellView: View {
    
    let group: BioRodeoResultGroup
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(alignment: .top, spacing: AppSpace.sm) {
                Text(group.rodeoName)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                Text("\(group.results.count)")
                    .font(.appCaptionStrong)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, AppSpace.sm)
                    .padding(.vertical, AppSpace.xxs)
                    .background(
                        Capsule()
                            .fill(Color.appSecondary.opacity(0.2))
                    )
            }
            
            HStack(spacing: AppSpace.xs) {
                Text(group.location)
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
                
                Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                
                Text(group.endDate.medium)
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
            }
            
            ForEach(group.results.indices, id: \.self) { index in
                let result = group.results[index]
                
                HStack(spacing: AppSpace.sm) {
                    Text(result.roundDisplay)
                        .font(.appCaptionStrong)
                        .foregroundColor(.appSecondary)
                        .frame(width: 68, alignment: .leading)
                    
                    Text(result.placeDisplay)
                        .font(.appRank)
                        .foregroundColor(.appSecondary)
                        .frame(width: 54, alignment: .leading)
                    
                    Spacer()
                    
                    Text(result.resultDisplay)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.appPrimary)
                        .monospacedDigit()
                        .frame(width: 74, alignment: .trailing)
                    
                    Text(result.payoutDisplay)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.appPrimary)
                        .monospacedDigit()
                        .frame(width: 96, alignment: .trailing)
                }
                
                if index != group.results.count - 1 {
                    Divider()
                        .overlay(Color.appTertiary.opacity(0.25))
                }
            }
        }
        .appCardStyle()
    }
}

struct BioResultCellView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BioView(athleteId: 59836)
                .tint(.appSecondary)
        }
    }
}
