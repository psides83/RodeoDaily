//
//  NFRContestantCard.swift
//  RodeoDaily
//

import SwiftUI

struct NFRContestantCard: View {
    let contestant: NFRContestant

    private var leftRounds: [NFRRoundResult] {
        Array(contestant.rounds.prefix(5))
    }

    private var rightRounds: [NFRRoundResult] {
        Array(contestant.rounds.dropFirst(5))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xxl) {
            HStack(alignment: .center, spacing: AppSpace.lg) {
                Text(contestant.worldPlace.string)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(.appPrimary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.appSecondary.opacity(0.10))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.appSecondary.opacity(0.28), lineWidth: AppStroke.hairline)
                    )

                VStack(alignment: .leading, spacing: AppSpace.xs) {
                    Text(contestant.name)
                        .font(.appCardTitle)
                        .foregroundColor(.appPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(contestant.averageDisplayValue)
                        .font(.appBodyStrong)
                        .foregroundColor(.appSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: AppSpace.lg)
            }

            Divider()
                .frame(height: 2)
                .background(Color.appSecondary)

            HStack(alignment: .top, spacing: AppSpace.xxl) {
                Spacer()

                roundColumn(leftRounds)

                Spacer()

                roundColumn(rightRounds)

                Spacer()
            }
        }
        .padding(AppSpace.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(Color.appBg)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(Color.appTertiary.opacity(0.28), lineWidth: AppStroke.hairline)
        }
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.appSecondary.opacity(0.45),
                            Color.appTertiary.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: AppStroke.hairline
                )
        }
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    private func roundColumn(_ rounds: [NFRRoundResult]) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.xl) {
            ForEach(rounds) { round in
                NFRRoundResultView(round: round)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
