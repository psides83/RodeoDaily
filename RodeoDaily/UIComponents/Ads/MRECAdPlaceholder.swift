//
//  MRECAdPlaceholder.swift
//  RodeoDaily
//

import SwiftUI

struct MRECAdPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xl) {
            Text("Ad")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpace.sm)
                .padding(.vertical, AppSpace.xs)
                .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: AppRadius.sm))

            VStack(alignment: .leading, spacing: AppSpace.md) {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(Color.secondary.opacity(0.14))
                    .frame(height: 96)

                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(Color.secondary.opacity(0.14))
                    .frame(height: 18)

                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(maxWidth: 220)
                    .frame(height: 14)
            }

            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appSecondary.opacity(0.18))
                    .frame(width: 104, height: 34)
            }
        }
        .padding(AppSpace.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(Color.secondary.opacity(0.18), lineWidth: AppStroke.hairline)
        )
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
    }
}
