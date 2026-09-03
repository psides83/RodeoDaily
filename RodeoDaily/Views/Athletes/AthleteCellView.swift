//
//  AthleteCellView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/24/24.
//

import SwiftUI

struct AthleteCellView: View {
    let athlete: WidgetAthlete
    
    var body: some View {
        HStack(alignment: .center, spacing: AppSpace.md) {
            VStack(alignment: .leading, spacing: AppSpace.xs) {
                Text(athlete.name)
                    .foregroundColor(.appPrimary)
                    .font(.appCardTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(athlete.event.eventDisplay)
                    .font(.appCaptionStrong)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, AppSpace.sm)
                    .padding(.vertical, AppSpace.xxs)
                    .appGlassSurface(
                        Capsule(style: .continuous),
                        tint: Color.appBg,
                        strokeOpacity: 0.12,
                        shadowOpacity: 0.01
                    )
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTertiary)
        }
        .appSectionSurface()
    }
}

#Preview {
    AthleteCellView(athlete: WidgetAthlete(athleteId: 72983, name: "", event: "TR", events: ["TR"]))
}
