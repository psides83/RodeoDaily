//
//  WatchToolbarIconButton.swift
//  RodeoDailyWatchApp
//

import SwiftUI

struct WatchToolbarIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(isDisabled ? .secondary : Color.appSecondary)
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.appSecondary.opacity(isDisabled ? 0.2 : 0.5), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
    }
}
