import SwiftUI

struct BusinessJournalFeedCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.20))
                .frame(height: 20)
                .frame(maxWidth: 210, alignment: .leading)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.16))
                .frame(height: 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: AppSpace.xs) {
                capsule(width: 110)
                capsule(width: 100)
            }

            HStack(spacing: AppSpace.xs) {
                capsule(width: 90)
                capsule(width: 120)
            }

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.16))
                .frame(height: 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appTertiary.opacity(0.16))
                .frame(height: 16)
                .frame(maxWidth: 260, alignment: .leading)
        }
        .redacted(reason: .placeholder)
        .appCardStyle()
    }

    private func capsule(width: CGFloat) -> some View {
        Capsule()
            .fill(Color.appTertiary.opacity(0.18))
            .frame(width: width, height: 24)
    }
}

struct BusinessJournalFeedCard: View {
    private struct TourBadgeStyle {
        let foreground: Color
        let start: Color
        let end: Color
        let border: Color
        let icon: String
    }

    let item: BusinessJournalFeedItem

    var body: some View {
        rowContent
            .appCardStyle()
    }

    private var rowContent: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Text(item.title)
                .foregroundStyle(Color.appPrimary)
                .font(.appCardTitle)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if let subtitle = item.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .foregroundStyle(Color.appSecondary)
                    .font(.appBody)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }

            if let source = item.source,
               let displayTour = displayTourLabel(from: source) {
                tourBadge(displayTour)
            }

            HStack(spacing: AppSpace.xs) {
                if let dateText = item.dateText, !dateText.isEmpty {
                    chip(icon: "calendar", text: dateText, color: .appSecondary)
                }
                
                if let locationText = item.locationText, !locationText.isEmpty {
                    chip(icon: "mappin.and.ellipse", text: locationText, color: .appSecondary)
                }
            }
            
            HStack(spacing: AppSpace.xs) {
                if let statusText = item.statusText, !statusText.isEmpty {
                    chip(icon: "flag", text: statusText, color: .appTertiary)
                }

                if let perfsText = item.perfsText, !perfsText.isEmpty {
                    chip(icon: "person.3", text: perfsText, color: .appSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTertiary)
                    .font(.caption)
            }
            
            if let eventsText = item.eventsText, !eventsText.isEmpty {
                Text(eventsText)
                    .font(.appBody)
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if let specialFeesText = item.specialEntryFeesText, !specialFeesText.isEmpty {
                (
                    Text("Special Entry Fees: ")
                        .font(.appBodyStrong)
                        .foregroundStyle(Color.appPrimary)
                    +
                    Text(specialFeesText)
                        .font(.appBody)
                        .foregroundStyle(Color.appPrimary)
                )
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func chip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.appCaptionStrong)
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppSpace.xs)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.appBg.opacity(0.55))
        )
    }

    private func tourBadge(_ source: String) -> some View {
        let style = styleForTour(source)
        return HStack(spacing: AppSpace.xs) {
//            Image(systemName: style.icon)
//                .font(.caption2.weight(.bold))
            Text(source.uppercased())
                .font(.appCaptionStrong.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(style.foreground)
        .padding(.vertical, 6)
        .padding(.horizontal, AppSpace.sm)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [style.start, style.end],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(style.border, lineWidth: AppStroke.hairline)
        )
    }

    private func styleForTour(_ source: String) -> TourBadgeStyle {
        let token = source.lowercased()

        if token == "cn" || token.contains("canada") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.78, green: 0.12, blue: 0.17),
                end: Color(red: 0.56, green: 0.06, blue: 0.10),
                border: Color(red: 0.92, green: 0.45, blue: 0.49),
                icon: "rosette"
            )
        }

        if token == "npp" || token.contains("permit") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.10, green: 0.43, blue: 0.77),
                end: Color(red: 0.06, green: 0.27, blue: 0.54),
                border: Color(red: 0.43, green: 0.67, blue: 0.91),
                icon: "person.badge.plus"
            )
        }

        if token.contains("playoff") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.52, green: 0.11, blue: 0.64),
                end: Color(red: 0.32, green: 0.06, blue: 0.43),
                border: Color(red: 0.73, green: 0.40, blue: 0.82),
                icon: "trophy"
            )
        }

        if token.contains("x-bulls") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.16, green: 0.13, blue: 0.49),
                end: Color(red: 0.09, green: 0.07, blue: 0.31),
                border: Color(red: 0.46, green: 0.40, blue: 0.86),
                icon: "bolt.shield"
            )
        }

        if token.contains("x-broncs") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.82, green: 0.39, blue: 0.06),
                end: Color(red: 0.56, green: 0.22, blue: 0.03),
                border: Color(red: 0.95, green: 0.61, blue: 0.31),
                icon: "hare"
            )
        }

        if token.contains("legacy") || token.contains("steer roping") {
            return TourBadgeStyle(
                foreground: Color.white,
                start: Color(red: 0.18, green: 0.44, blue: 0.18),
                end: Color(red: 0.10, green: 0.28, blue: 0.10),
                border: Color(red: 0.45, green: 0.72, blue: 0.45),
                icon: "lasso.badge.sparkles"
            )
        }

        let hue = hashHue(for: token)
        return TourBadgeStyle(
            foreground: Color.white,
            start: Color(hue: hue, saturation: 0.72, brightness: 0.70),
            end: Color(hue: hue, saturation: 0.82, brightness: 0.45),
            border: Color(hue: hue, saturation: 0.50, brightness: 0.90),
            icon: "flag"
        )
    }

    private func displayTourLabel(from source: String) -> String? {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed.lowercased()
        if normalized == "npp" || normalized == "cn" {
            return nil
        }

        return trimmed
    }

    private func hashHue(for token: String) -> Double {
        let sum = token.unicodeScalars.reduce(0) { partial, scalar in
            partial &+ Int(scalar.value)
        }
        return Double(sum % 360) / 360.0
    }
}

#Preview("PBJ Feed Card") {
    ZStack {
        Color.appBg.ignoresSafeArea()
        BusinessJournalFeedCard(
            item: BusinessJournalFeedItem(
                id: "preview-rodeo-1",
                title: "San Angelo Stock Show & Rodeo",
                subtitle: "PRCA ProRodeo with major weekend performances.",
                dateText: "Apr 10 - Apr 21",
                eventSortDate: nil,
                eventStartDate: nil,
                eventEndDate: nil,
                publishDate: nil,
                locationText: "San Angelo, TX",
                statusText: "Entries Open",
                eventsText: "BB, SW, SB, TR, BR",
                perfsText: "Perf 1-4",
                specialEntryFeesText: "BB-$70; SB-$70; BR-$70; TD-$175; SW-$175; TR-$175",
                addedMoneyText: "$430,000",
                addedMoneyTotal: 430000,
                entryWindowText: "Mar 29 - Apr 1",
                source: "PRCA",
                link: URL(string: "https://pbj.prorodeo.org"),
                detailFields: [
                    PBJDetailField(id: "rodeo_name", key: "rodeo_name", label: "Rodeo Name", value: "San Angelo Stock Show & Rodeo"),
                    PBJDetailField(id: "added_money", key: "added_money", label: "Added Money", value: "$430,000")
                ]
            )
        )
        .padding()
    }
}
