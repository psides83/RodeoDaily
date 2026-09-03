//
//  RodeoCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct RodeoCell: View {
    
    let rodeo: RodeoData
    
    var inProgress: String {
        if rodeo.inProgress {
            return "In Progress"
        } else {
            return ""
        }
    }

    private func displayDate(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix("0001-01-01") {
            return "TBD"
        }
        return raw.medium
    }

    private var dateRangeDisplay: String {
        let start = displayDate(rodeo.startDate)
        let end = displayDate(rodeo.endDate)

        if start == "TBD" && end == "TBD" {
            return "Dates TBD"
        }
        if start == end {
            return start
        }
        return "\(start) - \(end)"
    }

    private var tagTitles: [String] {
        rodeo.tourTitles
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: AppSpace.md) {
            VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text(rodeo.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.appPrimary)
                        .font(.appCardTitle)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    HStack(spacing: AppSpace.xs) {
                        Text(rodeo.location)
                            .font(.subheadline)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                        
                        Text(String(format: NSLocalizedString("Added: %@", comment: ""), rodeo.payout.currencyABS))
                            .foregroundColor(.appTertiary)
                            .font(.subheadline)
                        
                    }

                    if !tagTitles.isEmpty || rodeo.inProgress {
                        HStack(spacing: 6) {
                            ForEach(tagTitles, id: \.self) { tag in
                                Text(tag)
                                    .foregroundColor(.appSecondary)
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .appGlassSurface(
                                        Capsule(style: .continuous),
                                        tint: Color.appBg,
                                        strokeOpacity: 0.12,
                                        shadowOpacity: 0.01
                                    )
                            }
                        }
                    }

                    HStack {
                        Text(dateRangeDisplay)
                            .foregroundColor(.appPrimary)
                            .font(.appMetricValue)
                        
                        Spacer()
                        
                        if rodeo.inProgress {
                            Text(inProgress)
                                .foregroundColor(.appBg)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Capsule(style: .continuous).fill(Color.appSecondary))
                        }
                    }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appSecondary)
        }
        .appSectionSurface()
    }
}

struct RodeoCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
