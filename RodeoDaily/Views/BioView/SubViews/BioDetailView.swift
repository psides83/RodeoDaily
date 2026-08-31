import SwiftUI
import Foundation

struct BioDetailView: View {
    let athleteName: String
    let biographyText: String
    private let parsed: BioDetailDocument
    private let hasNoBioContent: Bool

    init(athleteName: String, biographyText: String) {
        self.athleteName = athleteName
        self.biographyText = biographyText
        let plainText = BioDetailParser
            .htmlToPlainText(biographyText)
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.hasNoBioContent = plainText.isEmpty
        self.parsed = hasNoBioContent ? BioDetailDocument(blocks: []) : BioDetailParser.parse(html: biographyText)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if hasNoBioContent {
                    noBioState
                } else if parsed.isEmpty {
                    HtmlView(htmlContent: biographyText)
                } else {
                    nativeBioContent
                }
                BannerAd(placement: .athleteBioSection)
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .navigationTitle(athleteName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.track(.athleteBioViewed(source: "bio_detail"))
        }
    }

    private var noBioState: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            Text(NSLocalizedString("No Bio Available", comment: ""))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(
                String(
                    format: NSLocalizedString("%@ does not have a published bio yet.", comment: ""),
                    athleteName
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpace.md)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
        )
        .padding(.bottom, AppSpace.sm)
    }

    private var nativeBioContent: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            ForEach(Array(parsed.blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .heading(let text):
                    Text(text)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.top, AppSpace.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .keyValue(let key, let value):
                    HStack(alignment: .firstTextBaseline, spacing: AppSpace.xs) {
                        Text("\(key):")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(value)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                case .paragraph(let text):
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .bullet(let text):
                    HStack(alignment: .firstTextBaseline, spacing: AppSpace.xs) {
                        Text("\u{2022}")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(text)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
