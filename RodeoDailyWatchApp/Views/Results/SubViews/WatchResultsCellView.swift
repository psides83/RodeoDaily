//
//  WatchResultsCellView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI
import WatchKit

struct WatchResultsCellView: View {
    // MARK: - Properties
    let winner: Winner
    let event: Events.CodingKeys
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            Text(winner.placeDisplay)
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(winner.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                
                HStack {
                    Text(winner.result)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(winner.earningsABS)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                WatchQuickAthleteStore.toggleFavorite(
                    athleteId: winner.contestantId,
                    name: winner.name,
                    event: event.rawValue
                )
                WatchQuickAthleteStore.playHapticForQuickAction()
            } label: {
                Label(
                    WatchQuickAthleteStore.isFavorite(athleteId: winner.contestantId) ? "Remove Favorite" : "Add Favorite",
                    systemImage: WatchQuickAthleteStore.isFavorite(athleteId: winner.contestantId) ? "star.slash" : "star"
                )
            }
            .tint(.yellow)

        }
    }
}

struct WatchResultsCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeoResultsView(rodeoId: 12867, rodeoName: "", event: .td)
    }
}

struct WatchQuickAthlete: Codable, Identifiable, Equatable {
    let athleteId: Int
    let name: String
    let event: String

    var id: Int { athleteId }
}

enum WatchQuickAthleteStore {
    private static let appGroup = "group.PaytonSides.RodeoDailyWatch"
    private static let favoritesKey = "watchFavoriteAthletes"
    private static let followedKey = "watchFollowedAthletes"
    private static let hapticsEnabledKey = "watchQuickActionHapticsEnabled"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }

    static func favorites() -> [WatchQuickAthlete] {
        guard let data = defaults?.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([WatchQuickAthlete].self, from: data)
        else { return [] }

        return decoded
    }

    static func followed() -> [WatchQuickAthlete] {
        guard let data = defaults?.data(forKey: followedKey),
              let decoded = try? JSONDecoder().decode([WatchQuickAthlete].self, from: data)
        else { return [] }

        return decoded
    }

    static func isFavorite(athleteId: Int) -> Bool {
        favorites().contains { $0.athleteId == athleteId }
    }

    static func isFollowed(athleteId: Int) -> Bool {
        followed().contains { $0.athleteId == athleteId }
    }

    static func toggleFavorite(athleteId: Int, name: String, event: String) {
        var items = favorites()

        if let idx = items.firstIndex(where: { $0.athleteId == athleteId }) {
            items.remove(at: idx)
        } else {
            items.append(WatchQuickAthlete(athleteId: athleteId, name: name, event: event))
        }

        persist(items: items, key: favoritesKey)
    }

    static func toggleFollow(athleteId: Int, name: String, event: String) {
        var items = followed()

        if let idx = items.firstIndex(where: { $0.athleteId == athleteId }) {
            items.remove(at: idx)
        } else {
            items.append(WatchQuickAthlete(athleteId: athleteId, name: name, event: event))
        }

        persist(items: items, key: followedKey)
    }

    static func clearFavorites() {
        persist(items: [], key: favoritesKey)
    }

    static func clearFollowed() {
        persist(items: [], key: followedKey)
    }

    static func playHapticForQuickAction() {
        let enabled = defaults?.object(forKey: hapticsEnabledKey) == nil
            ? true
            : (defaults?.bool(forKey: hapticsEnabledKey) ?? true)

        guard enabled else { return }
        WKInterfaceDevice.current().play(.click)
    }

    private static func persist(items: [WatchQuickAthlete], key: String) {
        let encoded = (try? JSONEncoder().encode(items)) ?? Data()
        defaults?.set(encoded, forKey: key)
    }
}
