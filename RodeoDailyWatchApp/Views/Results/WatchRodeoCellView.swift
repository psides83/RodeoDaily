//
//  WatchRodeoCellView.swift
//  RodeoDailyWatchApp
//
//  Created by Payton Sides on 3/5/23.
//

import SwiftUI

struct WatchRodeoCellView: View {
    
    let rodeo: RodeoData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(rodeo.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            
            Text(rodeo.location)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            Text(dateDisplay)
                .font(.caption2.monospacedDigit())
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }

    private var dateDisplay: String {
        let start = parseDate(rodeo.startDate)
        let end = parseDate(rodeo.endDate)

        if let start, let end {
            if Calendar.current.isDate(start, inSameDayAs: end) {
                return start.dateOnly
            }
            return "\(start.dateOnly) - \(end.dateOnly)"
        }

        if let start { return start.dateOnly }
        if let end { return end.dateOnly }
        return ""
    }

    private func parseDate(_ value: String) -> Date? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) { return date }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        for format in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd", "MM/d/yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) { return date }
        }

        return nil
    }
}

struct WatchRodeoCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeosListView()
    }
}
