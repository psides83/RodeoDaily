//
//  WinnerCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftData
import SwiftUI
import WidgetKit

struct WinnerCell: View {
    @Environment(\.modelContext) private var modelContext

    let event: String
    let winner: Winner
    var widgetAthletes: [WidgetAthlete]
    
    @State private var isShowingBio = false

    var body: some View {
        VStack {
            HStack {
                Text(winner.placeDisplay)
                    .font(.headline)
                    .foregroundColor(.appSecondary)
   
                winner.image
                    .shadow(radius: 4, x: 0, y: 4)
                
                VStack(alignment: .leading) {
                    NavigationLink {
                        BioView(athleteId: winner.contestantId)
                    } label: {
                        HStack {
                            Text(winner.name)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.appPrimary)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            favoriteIcon
                        }
                    }
                    .buttonStyle(.borderless)
                    
                    Text(winner.hometownDisplay)
                        .font(.caption)
                        .foregroundColor(.appTertiary)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text(winner.result)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    
                    Text(winner.earnings)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 90, alignment: .trailing)
                }
                .frame(width: 150)
            }
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
    
    var isFavorite: Bool {
        if widgetAthletes.contains(where: { $0.athleteId == winner.contestantId }) {
            return true
        }
        
        return false
    }
    
    @ViewBuilder
    var favoriteIcon: some View {
        switch isFavorite {
        case true:
            Image(systemName: "star.fill")
                .foregroundColor(.appSecondary)
        case false:
            EmptyView()
        }
    }

    private var nextAthleteSortOrder: Int {
        max((widgetAthletes.compactMap(\.sortOrder).max() ?? -1) + 1, widgetAthletes.count)
    }

    private func addFavoriteAthlete() {
        guard !isFavorite else { return }

        let widgetEvent = StandingsEvent(rawValue: event)?.withTeamRopingConversion ?? event
        let athlete = WidgetAthlete(
            athleteId: winner.contestantId,
            name: winner.name,
            event: widgetEvent,
            events: [widgetEvent],
            sortOrder: nextAthleteSortOrder
        )

        modelContext.insert(athlete)

        do {
            try modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            FavoriteAlert.added(winner.name).present
        } catch {
            modelContext.delete(athlete)
        }
    }
}

struct WinnerCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
