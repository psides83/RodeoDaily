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
                    .fill(Color.appBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.bottom)
    }
}
