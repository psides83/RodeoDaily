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

    var totalPayoff: Double {
        results.reduce(0) { $0 + $1.payoff }
    }

    var totalPayoffDisplay: String {
        totalPayoff == 0 ? "-  " : totalPayoff.currencyABS
    }

    var displayResults: [BioResult] {
        results.sorted { lhs, rhs in
            let lhsRank = roundSortRank(lhs.round)
            let rhsRank = roundSortRank(rhs.round)

            if lhsRank == rhsRank {
                return lhs.rodeoResultId < rhs.rodeoResultId
            }

            return lhsRank < rhsRank
        }
    }

    private func roundSortRank(_ round: String) -> Int {
        let normalized = round.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if let roundNumber = Int(normalized) {
            return roundNumber
        }

        if normalized == "finals" || normalized == "final" {
            return 9_998
        }

        if normalized == "avg" || normalized == "ave" || normalized == "average" {
            return 9_999
        }

        return 9_000
    }
}

struct BioResultCellView: View {
    
    let group: BioRodeoResultGroup
    
    // MARK: - Body
    var body: some View {
        let displayResults = group.displayResults

        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack(alignment: .top, spacing: AppSpace.sm) {
                Text(group.rodeoName)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                    .lineLimit(2)
                
                Spacer()

                VStack(alignment: .trailing, spacing: AppSpace.xxs) {
                    Text(group.totalPayoffDisplay)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.appPrimary)
                        .monospacedDigit()
                }
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
            
            ForEach(displayResults.indices, id: \.self) { index in
                let result = displayResults[index]
                
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
                
                if index != displayResults.count - 1 {
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
