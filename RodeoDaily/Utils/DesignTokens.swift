//
//  DesignTokens.swift
//  RodeoDaily
//
//  Created by Codex on 2/19/26.
//

import SwiftUI

enum AppSpace {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 10
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 24
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}

enum AppStroke {
    static let hairline: CGFloat = 1
}

extension Font {
    static let appCaption = Font.system(size: 12, weight: .regular)
    static let appCaptionStrong = Font.system(size: 12, weight: .semibold)
    static let appBody = Font.system(size: 15, weight: .regular)
    static let appBodyStrong = Font.system(size: 15, weight: .semibold)
    static let appRowTitle = Font.system(size: 17, weight: .semibold)
    static let appStat = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let appRank = Font.system(size: 16, weight: .bold, design: .rounded)
    static let appSectionTitle = Font.system(size: 22, weight: .bold)
    static let appCardTitle = Font.system(size: 19, weight: .bold)
    static let appMetricLabel = Font.system(size: 11, weight: .semibold)
    static let appMetricValue = Font.system(size: 15, weight: .bold, design: .rounded)
}

extension View {
    func appCardStyle() -> some View {
        self
            .padding(AppSpace.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(Color.appBg.opacity(0.92))
            )
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.18), lineWidth: AppStroke.hairline)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            .padding(.bottom)
    }

    func appSectionSurface() -> some View {
        self
            .padding(AppSpace.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(Color.appBg.opacity(0.68))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.14), lineWidth: AppStroke.hairline)
            )
            .padding(.bottom, AppSpace.sm)
    }

    func appInlineRowSurface() -> some View {
        self
            .padding(AppSpace.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(Color.appBg.opacity(0.58))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.12), lineWidth: AppStroke.hairline)
            )
    }

    func appGlassSurface<S: InsettableShape>(
        _ shape: S,
        tint: Color = Color.appBg,
        strokeOpacity: Double = 0.2,
        shadowOpacity: Double = 0.05
    ) -> some View {
        self
            .background {
                shape
                    .fill(tint.opacity(0.72))
                    .background(shape.fill(.ultraThinMaterial))
                    .overlay(
                        shape
                            .strokeBorder(Color.appTertiary.opacity(strokeOpacity), lineWidth: AppStroke.hairline)
                    )
                    .shadow(color: Color.black.opacity(shadowOpacity), radius: 10, x: 0, y: 4)
            }
    }

    func appFilterChipStyle() -> some View {
        self
            .padding(.vertical, AppSpace.sm)
            .padding(.horizontal, AppSpace.md)
            .appGlassSurface(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous),
                tint: Color.appBg,
                strokeOpacity: 0.18,
                shadowOpacity: 0.03
            )
    }

    func appCollapsedHeaderStyle() -> some View {
        self
            .padding(.horizontal, AppSpace.lg)
            .padding(.vertical, AppSpace.xs)
            .padding(.horizontal, AppSpace.sm)
            .appGlassSurface(
                Capsule(style: .continuous),
                tint: Color.appBg,
                strokeOpacity: 0.2,
                shadowOpacity: 0.06
            )
    }
}
