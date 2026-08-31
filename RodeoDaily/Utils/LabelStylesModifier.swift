//
//  LabelStylesModifier.swift
//  RodeoDaily
//
//  Created by Payton Sides on 8/29/26.
//

import SwiftUI

// MARK: - 1. Text first, icon after
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.title
            configuration.icon
        }
    }
}

// MARK: - 2. Icon – two-line text – icon
struct LeadingAndTrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
            configuration.title
            configuration.icon
        }
    }
}

// MARK: - Convenience extensions
extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

extension LabelStyle where Self == LeadingAndTrailingIconLabelStyle {
    static var leadingAndTrailingIcon: LeadingAndTrailingIconLabelStyle { LeadingAndTrailingIconLabelStyle() }
}
