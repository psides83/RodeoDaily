//
//  BioTelegramHeaderView.swift
//  RodeoDaily
//
//  Created by Codex on 5/2/26.
//

import SwiftUI

struct BioTelegramHeaderView: View {
    @ObservedObject var viewModel: BioViewModel
    static let expandedHeight: CGFloat = 474
    static let collapsedHeight: CGFloat = 228

    private var collapseDistance: CGFloat { expandedContainerHeight - collapsedContainerHeight }
    private var slideOffset: CGFloat {
        min(max(viewModel.bioScrollOffset, 0), collapseDistance)
    }

    private var progress: CGFloat {
        guard collapseDistance > 0 else { return 1 }
        return slideOffset / collapseDistance
    }

    private var detailsProgress: CGFloat {
        let smoothed = progress * progress * (3 - (2 * progress))
        return smoothed
    }

    private var pullProgress: CGFloat {
        let revealDistance: CGFloat = 120
        let value = viewModel.bioPullDownOffset / revealDistance
        return min(max(value, 0), 1)
    }

    private var collapsedContainerHeight: CGFloat { Self.collapsedHeight }
    private var expandedContainerHeight: CGFloat { Self.expandedHeight }

    private var heroExpandedHeight: CGFloat { expandedContainerHeight - collapsedContainerHeight }
    private var heroHeight: CGFloat {
        max(0, heroExpandedHeight * (1 - progress))
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            let totalHeight = topInset + expandedContainerHeight

            ZStack(alignment: .top) {
                headerBackground(topInset: topInset)

                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: topInset)
                    Color.clear.frame(height: heroHeight)
                    contentBlock
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .offset(y: -slideOffset)
            .frame(height: totalHeight, alignment: .top)
            .clipped()
        }
        .frame(height: expandedContainerHeight)
    }

    @ViewBuilder
    private func headerBackground(topInset: CGFloat) -> some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Color.rdGreen

                viewModel.bio.image
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
                    .opacity(1 - progress)
                    .offset(y: -(progress * 280))

                LinearGradient(
                    colors: [
                        .black.opacity(0.55),
                        .black.opacity(0.20),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(1 - progress)

                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.10),
                        .black.opacity(0.30),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(1 - progress)

                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: topInset + 64)
                    .mask {
                        LinearGradient(
                            colors: [
                                .black,
                                .black.opacity(0.85),
                                .black.opacity(0.25),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .ignoresSafeArea(edges: .top)
                    .opacity(progress)
            }
        }
    }

    private var contentBlock: some View {
        VStack(spacing: AppSpace.md) {
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(viewModel.bio.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(viewModel.selectedEvent?.eventDisplay ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: 10 * progress)

            VStack(spacing: AppSpace.sm) {
                Text(viewModel.seasonRanking())
                    .font(.appBodyStrong)
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: AppSpace.sm) {
                    statPill(viewModel.bio.nfrQuals)
                    statPill(viewModel.bio.worldTitlesCount)
                    statPill(viewModel.bio.athleteAge + NSLocalizedString(" Years old", comment: ""))
                }
            }
            .opacity(1 - detailsProgress)
            .offset(y: -10 * detailsProgress)
            .frame(height: 78 * (1 - detailsProgress), alignment: .top)
            .clipped()

            Picker("", selection: $viewModel.infoType) {
                ForEach(BioViewModel.BioInfoType.allCases, id: \.self) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(AppSpace.xxs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.85))
            )
            .offset(y: -6)
        }
        .padding(.horizontal, AppSpace.md)
        .padding(.top, AppSpace.sm)
        .padding(.bottom, AppSpace.sm)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func statPill(_ text: String) -> some View {
        Text(text)
            .font(.appCaptionStrong)
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpace.sm)
            .padding(.horizontal, AppSpace.xs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.65))
            )
    }
}
