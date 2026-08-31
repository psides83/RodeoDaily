import Foundation

struct BioDetailDocument {
    let blocks: [BioDetailBlock]

    var isEmpty: Bool {
        blocks.isEmpty
    }
}

enum BioDetailBlock: Identifiable {
    case heading(String)
    case keyValue(String, String)
    case paragraph(String)
    case bullet(String)

    var id: String {
        switch self {
        case .heading(let text):
            return "h:\(text)"
        case .keyValue(let key, let value):
            return "kv:\(key)|\(value)"
        case .paragraph(let text):
            return "p:\(text)"
        case .bullet(let text):
            return "b:\(text)"
        }
    }
}

enum BioDetailParser {
    static func parse(html: String) -> BioDetailDocument {
        let trimmed = html.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return BioDetailDocument(blocks: [])
        }

        let plain = htmlToPlainText(trimmed)
            .replacingOccurrences(of: "\u{00A0}", with: " ")
        let lines = plain
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var blocks: [BioDetailBlock] = []

        for line in lines where !line.isEmpty {
            if isSectionHeading(line) {
                blocks.append(.heading(line))
                continue
            }

            if line.hasPrefix("•") {
                let bulletText = line
                    .dropFirst()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !bulletText.isEmpty {
                    blocks.append(.bullet(bulletText))
                }
            } else if line.hasPrefix("- ") {
                let bulletText = line
                    .dropFirst(2)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !bulletText.isEmpty {
                    blocks.append(.bullet(bulletText))
                }
            } else if let kv = parseKeyValue(line) {
                blocks.append(.keyValue(kv.0, kv.1))
            } else {
                blocks.append(.paragraph(line))
            }
        }

        return BioDetailDocument(blocks: blocks)
    }

    private static func parseKeyValue(_ line: String) -> (String, String)? {
        guard let idx = line.firstIndex(of: ":") else { return nil }
        let key = String(line[..<idx]).trimmingCharacters(in: .whitespacesAndNewlines)
        let value = String(line[line.index(after: idx)...]).trimmingCharacters(in: .whitespacesAndNewlines)

        guard !key.isEmpty, !value.isEmpty else { return nil }
        guard key.count <= 48 else { return nil }
        guard !key.contains("  ") else { return nil }
        return (key, value)
    }

    private static func isSectionHeading(_ line: String) -> Bool {
        let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return false }

        let exact = Set([
            "Professional",
            "Personal",
            "Career Highlights",
            "2026 Highlights",
            "2025 Highlights",
            "2024 Highlights"
        ])

        if exact.contains(cleaned) { return true }
        if cleaned.hasSuffix("Highlights"), cleaned.count <= 24 { return true }
        return false
    }

    static func htmlToPlainText(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }

        return html
    }
}
