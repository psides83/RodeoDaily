import AlertKit
import SwiftData
import SwiftUI

struct BioFavoriteToolbarButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var widgetAthletes: [WidgetAthlete]

    @ObservedObject var viewModel: BioViewModel
    let athleteId: Int

    private var resolvedAthleteId: Int {
        viewModel.bio.contestantId != 0 ? viewModel.bio.contestantId : athleteId
    }

    private var isFavorite: Bool {
        widgetAthletes.contains(where: { $0.athleteId == resolvedAthleteId })
    }

    private var favoriteIcon: String {
        isFavorite ? "star.fill" : "star"
    }

    var body: some View {
        Button {
            handleFavorite()
        } label: {
            Image(systemName: favoriteIcon)
                .imageScale(.medium)
        }
        .tint(.appSecondary)
    }

    private func handleFavorite() {
        if let athlete = widgetAthletes.first(where: { $0.athleteId == resolvedAthleteId }) {
            modelContext.delete(athlete)
            FavoriteAlert.removed(athlete.name).present
            return
        }

        let favorite = WidgetAthlete()
        favorite.athleteId = resolvedAthleteId
        favorite.name = viewModel.bio.name
        favorite.event = viewModel.selectedEvent ?? viewModel.bio.topEvent.withTeamRopingConversion
        favorite.events = viewModel.bio.events
        modelContext.insert(favorite)
        FavoriteAlert.added(favorite.name).present
    }
}
