//
//  StandingsCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/11/22.
//

import SwiftData
import SwiftUI
import WidgetKit

struct StandingsCell: View {
    @Environment(\.modelContext) private var modelContext

    let position: Position
    
    var widgetAthletes: [WidgetAthlete]
    var followedAthletes: [FollowedAthlete]
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    rankBadge
                    
                    
                    VStack(alignment: .leading, spacing: AppSpace.xs) {
                        Text(position.name)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.appPrimary)
                            .font(.appCardTitle)
                            .lineLimit(2)
                        
                        if !position.hometownDisplay.isEmpty {
                            Text(position.hometownDisplay)
                                .font(.appCaption)
                                .foregroundColor(.appTertiary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                metrics
            }
            .appSectionSurface()
            
            position.image
                .scaleEffect(2.5)
                .offset(x: 20, y: -19)
                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                .padding(.trailing, AppSpace.xs)
        }
        .contextMenu {
            if isFavorite {
                Label(NSLocalizedString("Favorite", comment: ""), systemImage: "star.fill")
            } else {
                Button {
                    addFavoriteAthlete()
                } label: {
                    Label(NSLocalizedString("Add to Favorites", comment: ""), systemImage: "star.badge.plus")
                }
            }
        }
    }
    
    var rankBadge: some View {
        Text("#\(position.place)")
            .font(.appRank)
            .foregroundColor(.appBg)
            .padding(.horizontal, AppSpace.sm)
            .padding(.vertical, AppSpace.xs)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.appSecondary)
            )
    }
    
    var metrics: some View {
        VStack(alignment: .trailing, spacing: AppSpace.xs) {
            HStack {
                followedIcon
                favoriteIcon
                
                if position.hasBio {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appSecondary)
                }
            }
            
            Spacer()
            
            Text(position.standingsMetricTitle)
                .font(.appMetricLabel)
                .foregroundColor(.appTertiary)
                .textCase(.uppercase)
	            
            Text(position.standingsMetricValue)
                .font(.appMetricValue)
                .foregroundColor(.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
    
    var isFavorite: Bool {
        if widgetAthletes.contains(where: { $0.athleteId == position.id }) {
            return true
        }
        
        return false
    }
    
    var isFollowed: Bool {
        followedAthletes.contains(where: { $0.athleteId == position.id })
    }

    private var nextAthleteSortOrder: Int {
        max((widgetAthletes.compactMap(\.sortOrder).max() ?? -1) + 1, widgetAthletes.count)
    }

    private var widgetEvent: String {
        StandingsEvent(rawValue: position.event)?.withTeamRopingConversion ?? position.event
    }

    private func addFavoriteAthlete() {
        guard !isFavorite else { return }

        let athlete = WidgetAthlete(
            athleteId: position.id,
            name: position.name,
            event: widgetEvent,
            events: [widgetEvent],
            sortOrder: nextAthleteSortOrder
        )

        modelContext.insert(athlete)

        do {
            try modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            FavoriteAlert.added(position.name).present
        } catch {
            modelContext.delete(athlete)
        }
    }
    
    @ViewBuilder
    var followedIcon: some View {
        switch isFollowed {
        case true:
            Image(systemName: "bell.fill")
                .foregroundColor(.appSecondary)
                .accessibilityLabel("Followed")
        case false:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var favoriteIcon: some View {
        switch isFavorite {
        case true:
            Image(systemName: "star.fill")
                .foregroundColor(.appSecondary)
                .accessibilityLabel("Favorite")
        case false:
            EmptyView()
        }
    }
}

struct StandingsCell_Previews: PreviewProvider {
    static var previews: some View {
        //        let position = Position(id: 70406, firstName: "Caleb", lastName: "Smidt", event: "td", type: "", hometown: "Somewhere, TX", nickName: "Caleb", imageUrl: "", earnings: 15635.45, points: 15635.45, place: 6, standingId: 123, seasonYear: 2023, tourId: nil, circuitId: nil)
        //
        ContentView()
    }
}
