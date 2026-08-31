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
        let start = rodeo.startDate.rodeoDate
        let end = rodeo.endDate.rodeoDate

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
}

struct WatchRodeoCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeosListView()
    }
}
