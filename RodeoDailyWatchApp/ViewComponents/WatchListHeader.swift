//
//  WatchListHeader.swift
//  RodeoDailyWatchApp
//

import SwiftUI

struct WatchListHeader: View {
    let title: String
    let subtitle: String?
    let systemImage: String

    init(title: String, subtitle: String? = nil, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.rdGreen, in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .textCase(.none)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.none)
                }
            }
        }
    }
}
