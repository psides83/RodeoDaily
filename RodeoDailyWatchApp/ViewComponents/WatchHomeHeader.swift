//
//  WatchHomeHeader.swift
//  RodeoDailyWatchApp
//

import SwiftUI

struct WatchHomeHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            WatchLogo(size: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text("Rodeo Daily")
                    .font(.headline)
                    .textCase(.none)
            }
        }
        .padding(.vertical, 2)
    }
}
