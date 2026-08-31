//
//  NativeAdPlaceholder.swift
//  RodeoDaily
//

import SwiftUI

struct NativeAdPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            Text("Ad")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpace.sm)
                .padding(.vertical, AppSpace.xs)
                .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: AppRadius.sm))

            HStack(spacing: AppSpace.lg) {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.secondary.opacity(0.12))
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(Color.secondary.opacity(0.14))
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(width: 180, height: 13)
                }
            }

            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appSecondary.opacity(0.18))
                    .frame(width: 92, height: 30)
            }
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(Color.secondary.opacity(0.18), lineWidth: AppStroke.hairline)
        )
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
    }
}
