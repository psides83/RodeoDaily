//
//  VideoHighlightsView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI

struct VideoHighlightsView: View {
    @ObservedObject var viewModel: BioViewModel
    @State private var initialOffset: CGFloat?

    private let columns = [
        GridItem(.flexible(), spacing: AppSpace.md)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.lg) {
                Color.clear
                    .frame(height: 0)
                    .offset(coordinateSpcae: .named("BIO_SCROLL_SHARED")) { value in
                        if initialOffset == nil {
                            initialOffset = value
                            viewModel.bioScrollOffset = 0
                            viewModel.bioPullDownOffset = 0
                            return
                        }
                        if !viewModel.bioHasUserScrolled {
                            viewModel.bioScrollOffset = 0
                            viewModel.bioPullDownOffset = 0
                            return
                        }
                        let baseline = initialOffset ?? value
                        let delta = value - baseline
                        let newScroll = max(-delta, 0)
                        viewModel.bioScrollOffset = newScroll < 1 ? 0 : newScroll
                        viewModel.bioPullDownOffset = 0
                    }

                Color.clear
                    .frame(height: BioTelegramHeaderView.expandedHeight - 12)

                if videos.isEmpty {
                    emptyState
                    BannerAd(style: .mediumRectangle)
                } else {
                    header

                    LazyVGrid(columns: columns, spacing: AppSpace.md) {
                        ForEach(videos) { video in
                            VimeoPlayer(video: video.path)
                                .frame(height: videoHeight)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                                .padding(.vertical)
                        }
                    }

                    BannerAd(style: .mediumRectangle)
                }
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .simultaneousGesture(DragGesture(minimumDistance: 1)
            .onChanged { _ in
                viewModel.bioHasUserScrolled = true
            }
        )
        .onAppear {
            initialOffset = nil
        }
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
        .appCardStyle()
    }

    @ViewBuilder
    private var emptyState: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label("No Highlights Available", systemImage: "video.slash.fill")
            } description: {
                Text("\(viewModel.bio.name) doesn't have any highlights available. Videos will be added as they become available")
            }
        } else {
            UnavailableContentView(
                imageName: "video.slash.fill",
                title: "No Highlights Available",
                description: "\(viewModel.bio.name) doesn't have any highlights available. Videos will be added as they become available"
            )
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

    private var videoHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 32
        return (screenWidth / 16) * 9
    }
}

private struct HighlightVideo: Identifiable {
    let id: String
    let path: String
}
