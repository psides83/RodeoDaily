//
//  HomeNativeStyleHeader.swift
//  RodeoDaily
//
//  Created by Codex on 5/2/26.
//

import SwiftUI

struct HomeNativeStyleHeader: View {
    let title: String
    let subtitle: String?
    let scrollOffset: CGFloat

    private var collapseProgress: CGFloat {
        let start: CGFloat = 8
        let distance: CGFloat = 56
        let progress = (scrollOffset - start) / distance
        return min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            let compactHeight: CGFloat = 44
            let largeHeight: CGFloat = 54
            let totalHeight = topInset + compactHeight + (largeHeight * (1 - collapseProgress))

            ZStack(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(collapseProgress)
                    .frame(height: topInset + compactHeight)
                    .frame(maxHeight: .infinity, alignment: .top)

                VStack(spacing: 0) {
                    Color.clear.frame(height: topInset)

                    ZStack(alignment: .center) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .opacity(collapseProgress)
                            .padding(.horizontal, 64)

                        HStack {
                            Spacer()
                        }
                    }
                    .frame(height: compactHeight)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 34, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .opacity(1 - collapseProgress)
                    .offset(y: -10 * collapseProgress)
                }
            }
            .frame(height: totalHeight, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(height: 140)
        .allowsHitTesting(false)
    }
}

