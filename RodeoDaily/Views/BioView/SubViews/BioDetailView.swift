import SwiftUI
import Foundation

struct BioDetailView: View {
    let athleteName: String
    let biographyText: String
    @State private var parsedBio: ParsedBio?

    init(athleteName: String, biographyText: String) {
        self.athleteName = athleteName
        self.biographyText = biographyText
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let parsedBio {
                    if parsedBio.hasNoBioContent {
                        noBioState
                    } else if parsedBio.document.isEmpty {
                        HtmlView(htmlContent: biographyText)
                    } else {
                        nativeBioContent(parsedBio.document)
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpace.xxl)
                }
                BannerAd(placement: .athleteBioSection)
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg.ignoresSafeArea())
        .navigationTitle(athleteName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.track(.athleteBioViewed(source: "bio_detail"))
        }
        .task(id: biographyText) {
            parsedBio = Self.parseBiography(biographyText)
        }
    }

    private struct ParsedBio {
        let document: BioDetailDocument
        let hasNoBioContent: Bool
    }

    private static func parseBiography(_ biographyText: String) -> ParsedBio {
        let plainText = BioDetailParser
            .htmlToPlainText(biographyText)
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let hasNoBioContent = plainText.isEmpty
        let document = hasNoBioContent ? BioDetailDocument(blocks: []) : BioDetailParser.parse(html: biographyText)

        return ParsedBio(document: document, hasNoBioContent: hasNoBioContent)
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
        .appSectionSurface()
        .padding(.bottom, AppSpace.sm)
    }

    private func nativeBioContent(_ document: BioDetailDocument) -> some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            ForEach(Array(document.blocks.enumerated()), id: \.offset) { _, block in
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
