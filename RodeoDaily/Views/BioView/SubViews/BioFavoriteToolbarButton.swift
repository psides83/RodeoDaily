import AlertKit
import SwiftData
import SwiftUI

struct BioFavoriteToolbarButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WidgetAthlete.sortOrder) private var widgetAthletes: [WidgetAthlete]
    @State private var favoriteSaveError: String?

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
        .disabled(!isFavorite && !canCreateFavorite)
        .alert(
            Text("Unable to Add Favorite"),
            isPresented: Binding(
                get: { favoriteSaveError != nil },
                set: { if !$0 { favoriteSaveError = nil } }
            )
        ) {
            Button("OK") {
                favoriteSaveError = nil
            }
        } message: {
            Text(favoriteSaveError ?? "")
        }
    }

    private func handleFavorite() {
        if let athlete = widgetAthletes.first(where: { $0.athleteId == resolvedAthleteId }) {
            modelContext.delete(athlete)

            do {
                try modelContext.save()
            } catch {
                favoriteSaveError = error.localizedDescription
                print("[FavoriteAthlete] Failed deleting athlete ID \(resolvedAthleteId): \(error.localizedDescription)")
                return
            }

            FavoriteAlert.removed(athlete.name).present
            return
        }

        guard canCreateFavorite else {
            return
        }

        let favorite = WidgetAthlete()
        favorite.athleteId = viewModel.bio.contestantId
        favorite.name = viewModel.bio.name.trimmingCharacters(in: .whitespacesAndNewlines)
        favorite.event = viewModel.selectedEvent ?? viewModel.bio.topEvent.withTeamRopingConversion
        favorite.events = viewModel.bio.events
        favorite.sortOrder = nextAthleteSortOrder
        modelContext.insert(favorite)

        do {
            try modelContext.save()
        } catch {
            modelContext.delete(favorite)
            favoriteSaveError = String(
                format: NSLocalizedString("Unable to save %@ as a favorite. %@", comment: ""),
                favorite.name,
                error.localizedDescription
            )
            print("[FavoriteAthlete] SwiftData save failed for athlete ID \(favorite.athleteId): \(error.localizedDescription)")
            return
        }

        FavoriteAlert.added(favorite.name).present
    }

    private var canCreateFavorite: Bool {
        viewModel.bio.contestantId != 0 &&
            !viewModel.bio.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var nextAthleteSortOrder: Int {
        max((widgetAthletes.compactMap(\.sortOrder).max() ?? -1) + 1, widgetAthletes.count)
    }
}
