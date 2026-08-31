//
//  NFRRoundResultView.swift
//  RodeoDaily
//

import SwiftUI

struct NFRRoundResultView: View {
    let round: NFRRoundResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            Text(
                String(
                    format: NSLocalizedString("Round %d", comment: ""),
                    round.round
                )
            )
            .font(.appBodyStrong)
            .foregroundColor(.appPrimary)
            .overlay(alignment: .bottomLeading) {
                Capsule()
                    .fill(Color.appTertiary.opacity(0.5))
                    .frame(width: 80, height: 1)
                    .offset(y: 4)
            }

            Text(round.displayValue)
                .font(.appBodyStrong)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var valueColor: Color {
        if round.isPending {
            return Color.appTertiary
        }

        if round.hasResult {
            return Color.appPrimary
        }

        return Color.appSecondary
    }
}
