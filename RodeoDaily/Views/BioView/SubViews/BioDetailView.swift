import SwiftUI
import Foundation

struct BioDetailView: View {
    let athleteName: String
    let biographyText: String
    private let parsed: LocalBioDetailDocument
    private let hasNoBioContent: Bool

    init(athleteName: String, biographyText: String) {
        self.athleteName = athleteName
        self.biographyText = biographyText
        let plainText = LocalBioDetailParser
            .htmlToPlainText(biographyText)
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.hasNoBioContent = plainText.isEmpty
        self.parsed = hasNoBioContent ? LocalBioDetailDocument(blocks: []) : LocalBioDetailParser.parse(html: biographyText)
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
                BannerAd(style: .mediumRectangle)
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .navigationTitle(athleteName)
        .navigationBarTitleDisplayMode(.inline)
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

private struct LocalBioDetailDocument {
    let blocks: [LocalBioDetailBlock]
    var isEmpty: Bool { blocks.isEmpty }
}

private enum LocalBioDetailBlock {
    case heading(String)
    case keyValue(String, String)
    case paragraph(String)
    case bullet(String)
}

private enum LocalBioDetailParser {
    static func parse(html: String) -> LocalBioDetailDocument {
        let trimmed = html.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return LocalBioDetailDocument(blocks: []) }

        let plain = htmlToPlainText(trimmed).replacingOccurrences(of: "\u{00A0}", with: " ")
        let lines = plain
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var blocks: [LocalBioDetailBlock] = []
        for line in lines where !line.isEmpty {
            if isSectionHeading(line) {
                blocks.append(.heading(line))
                continue
            }
            if line.hasPrefix("•") {
                let t = String(line.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { blocks.append(.bullet(t)) }
            } else if line.hasPrefix("- ") {
                let t = String(line.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { blocks.append(.bullet(t)) }
            } else if let kv = parseKeyValue(line) {
                blocks.append(.keyValue(kv.0, kv.1))
            } else {
                blocks.append(.paragraph(line))
            }
        }
        return LocalBioDetailDocument(blocks: blocks)
    }

    private static func parseKeyValue(_ line: String) -> (String, String)? {
        guard let idx = line.firstIndex(of: ":") else { return nil }
        let key = String(line[..<idx]).trimmingCharacters(in: .whitespacesAndNewlines)
        let value = String(line[line.index(after: idx)...]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !value.isEmpty, key.count <= 48, !key.contains("  ") else { return nil }
        return (key, value)
    }

    private static func isSectionHeading(_ line: String) -> Bool {
        let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return false }
        let exact = Set(["Professional", "Personal", "Career Highlights", "2026 Highlights", "2025 Highlights", "2024 Highlights"])
        if exact.contains(cleaned) { return true }
        return cleaned.hasSuffix("Highlights") && cleaned.count <= 24
    }

    static func htmlToPlainText(_ html: String) -> String {
        html
            .replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "</p>", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
}
