//
//  WatchResultsTRCellView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI

struct WatchResultsTRCellView: View {
    // MARK: - Properties
    let index: Int
    let winners: [Winner]
    let event: Events.CodingKeys
    
    private var header: Winner? {
        guard winners.indices.contains(index) else { return nil }
        return winners[index]
    }
    
    private var heeler: Winner? {
        guard winners.indices.contains(index + 1) else { return nil }
        return winners[index + 1]
    }
    
    // MARK: - Body
    var body: some View {
        if let header {
            HStack(spacing: 8) {
                Text(header.placeDisplay)
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 20, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(header.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    
                    if let heeler {
                        Text(heeler.name)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Text(header.result)
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(header.earningsABS)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                    }
                }
            }
            .contentShape(Rectangle())
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    WatchQuickAthleteStore.toggleFavorite(
                        athleteId: header.contestantId,
                        name: header.name,
                        event: event.rawValue
                    )
                    WatchQuickAthleteStore.playHapticForQuickAction()
                } label: {
                    Label(
                        WatchQuickAthleteStore.isFavorite(athleteId: header.contestantId) ? "Remove Favorite" : "Add Favorite",
                        systemImage: WatchQuickAthleteStore.isFavorite(athleteId: header.contestantId) ? "star.slash" : "star"
                    )
                }
                .tint(.yellow)

                Button {
                    WatchQuickAthleteStore.toggleFollow(
                        athleteId: header.contestantId,
                        name: header.name,
                        event: event.rawValue
                    )
                    WatchQuickAthleteStore.playHapticForQuickAction()
                } label: {
                    Label(
                        WatchQuickAthleteStore.isFollowed(athleteId: header.contestantId) ? "Unfollow Athlete" : "Follow Athlete",
                        systemImage: WatchQuickAthleteStore.isFollowed(athleteId: header.contestantId) ? "bell.slash" : "bell"
                    )
                }
                .tint(.green)
            }
        }
    }
}

struct WatchResultsTRCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeoResultsView(rodeoId: 12867, rodeoName: "", event: .tr)
    }
}
