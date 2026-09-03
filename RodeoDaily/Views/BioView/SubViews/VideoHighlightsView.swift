//
//  VideoHighlightsView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI

struct VideoHighlightsView: View {
    @ObservedObject var viewModel: BioViewModel

    private let columns = [
        GridItem(.flexible(), spacing: AppSpace.md)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                Color.clear
                    .frame(height: BioTelegramHeaderView.expandedHeight - 12)

                if videos.isEmpty {
                    emptyState
                    BannerAd(placement: .athleteBioSection)
                } else {
                    header

                    GeometryReader { proxy in
                        LazyVGrid(columns: columns, spacing: AppSpace.md) {
                            ForEach(videos) { video in
                                VimeoPlayer(video: video.path)
                                    .frame(height: videoHeight(for: proxy.size.width))
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                                    .padding(.vertical)
                            }
                        }
                    }
                    .frame(height: totalVideoGridHeight(for: videos.count))

                    BannerAd(placement: .athleteBioSection)
                }
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .bioHeaderScrollTracking(viewModel)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpace.xxs) {
            Text("Highlights")
                .font(.appSectionTitle)
                .foregroundColor(.appPrimary)

            Text(viewModel.bio.name)
                .font(.appBodyStrong)
                .foregroundColor(.appSecondary)

            Text("\(videos.count) videos")
                .font(.appCaption)
                .foregroundColor(.appTertiary)
        }
        .appSectionSurface()
    }

    @ViewBuilder
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Highlights Available", systemImage: "video.slash.fill")
        } description: {
            Text("\(viewModel.bio.name) doesn't have any highlights available. Videos will be added as they become available")
        }
    }

    private var videos: [HighlightVideo] {
        guard let videosRaw = viewModel.bio.videoHighlights else { return [] }

        let paths = videosRaw
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.replacingOccurrences(of: "/videos", with: "/video") }

        var seen = Set<String>()
        var parsed: [HighlightVideo] = []

        for path in paths {
            guard let id = vimeoId(from: path), !seen.contains(id) else { continue }
            seen.insert(id)
            parsed.append(
                HighlightVideo(
                    id: id,
                    path: path
                )
            )
        }

        return parsed.sorted { $0.id > $1.id }
    }

    private func vimeoId(from path: String) -> String? {
        let segments = path.split(separator: "/").map(String.init)
        return segments.last(where: { !$0.isEmpty && $0.allSatisfy(\.isNumber) })
    }

    private func videoHeight(for width: CGFloat) -> CGFloat {
        (width / 16) * 9
    }

    private func totalVideoGridHeight(for count: Int) -> CGFloat {
        let rowHeight = videoHeight(for: 358) + (AppSpace.xl * 2)
        return CGFloat(count) * rowHeight + CGFloat(max(count - 1, 0)) * AppSpace.md
    }
}

private struct HighlightVideo: Identifiable {
    let id: String
    let path: String
}
