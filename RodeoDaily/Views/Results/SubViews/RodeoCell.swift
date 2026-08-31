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
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(rodeo.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.appPrimary)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(rodeo.location)
                            .font(.subheadline)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                        
                        Text("Added: \(rodeo.payout.currencyABS)")
                            .foregroundColor(.appTertiary)
                            .font(.subheadline)
                        
                    }
                    .padding(.bottom, 8)

                    if !tagTitles.isEmpty || rodeo.inProgress {
                        HStack(spacing: 6) {
                            ForEach(tagTitles, id: \.self) { tag in
                                Text(tag)
                                    .foregroundColor(.appSecondary)
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(RoundedRectangle(cornerRadius: 50).fill(Color.appSecondary.opacity(0.15)))
                            }
                        }
                        .padding(.bottom, 8)
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
                                .background(RoundedRectangle(cornerRadius: 50).fill(Color.appSecondary))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.appSecondary)
            }
        }
        .appCardStyle()
    }
}

struct RodeoCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
