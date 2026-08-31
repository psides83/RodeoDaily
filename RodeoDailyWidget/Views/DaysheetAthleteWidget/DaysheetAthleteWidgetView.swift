//
//  DaysheetAthleteWidgetView.swift
//  RodeoDailyWidget
//
//  Created by Codex on 5/16/26.
//

import SwiftUI
import WidgetKit

struct DaysheetAthleteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DaysheetAthleteWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemLarge ? 6 : 5) {
            header

            if let message = entry.message {
                Spacer(minLength: 0)
                unavailableView(message: message)
                Spacer(minLength: 0)
            } else {
                VStack(alignment: .leading, spacing: family == .systemLarge ? 6 : 5) {
                    ForEach(entry.items) { item in
                        Divider()
                            .overlay(Color.appSecondary)
                            .environment(\.colorScheme, .dark)

                        scheduleRow(item)
                    }
                }
            }

            Spacer(minLength: 0)

            if family == .systemLarge {
                updatedFooter
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.rdGreen
        }
        .environment(\.colorScheme, .dark)
        .widgetURL(entry.athleteBioURL)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.athleteName)
                    .font(.system(size: family == .systemLarge ? 22 : 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("Upcoming Rodeo Entries")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appSecondary)
            }

            Spacer()

            Image("rodeo-daily-iOS-icon-sm")
                .resizable()
                .frame(width: family == .systemLarge ? 32 : 28, height: family == .systemLarge ? 32 : 28)
        }
    }

    private func unavailableView(message: String) -> some View {
        VStack(alignment: .leading, spacing: family == .systemLarge ? 10 : 8) {
            ZStack {
                Circle()
                    .fill(Color.appSecondary.opacity(0.18))
                    .frame(width: family == .systemLarge ? 44 : 38, height: family == .systemLarge ? 44 : 38)

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: family == .systemLarge ? 22 : 19, weight: .semibold))
                    .foregroundColor(.appSecondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("No current day sheets")
                    .font(.system(size: family == .systemLarge ? 17 : 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(message)
                    .font(.system(size: family == .systemLarge ? 13 : 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.82))
                    .multilineTextAlignment(.leading)
                    .lineLimit(family == .systemLarge ? 3 : 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(family == .systemLarge ? 14 : 12)
        .background(
            RoundedRectangle(cornerRadius: family == .systemLarge ? 18 : 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: family == .systemLarge ? 18 : 16, style: .continuous)
                .stroke(Color.appSecondary.opacity(0.25), lineWidth: 1)
        )
    }

    private func scheduleRow(_ item: DaysheetAthleteScheduleItem) -> some View {
        VStack(alignment: .leading, spacing: family == .systemLarge ? 4 : 3) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(item.rodeoName)
                    .font(.system(size: family == .systemLarge ? 16 : 15, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text(item.dateText)
                    .font(.system(size: family == .systemLarge ? 13 : 12, weight: .medium))
                    .foregroundColor(.white)


                if item.isTurnout {
                    Text("TO")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white.opacity(0.75))
                }
            }

            HStack(spacing: 4) {
                Text(item.location)
                Text("•")
                Text(item.eventName)
                Text("•")
                Text(item.roundLabel)
            }
            .font(.system(size: family == .systemLarge ? 12 : 11, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(1)
        }
    }

    private var updatedFooter: some View {
        HStack {
            Spacer()
            Text(NSLocalizedString("Updated ", comment: "") + entry.date.medium)
                .foregroundColor(.white)
                .font(.caption)
        }
    }
}

#Preview(as: .systemLarge) {
    DaysheetAthleteWidget()
} timeline: {
    DaysheetAthleteWidgetEntry.placeholder
}
