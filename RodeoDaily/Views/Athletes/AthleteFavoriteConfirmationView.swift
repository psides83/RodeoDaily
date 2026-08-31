import SwiftUI

struct AthleteFavoriteConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BioViewModel()

    let suggestion: SearchResultElement
    let onConfirm: (BioData) -> Void

    private var hasCompetitionData: Bool {
        !viewModel.bio.events.isEmpty ||
            !viewModel.bio.rankings.isEmpty ||
            !viewModel.bio.earnings.isEmpty
    }

    private var canConfirm: Bool {
        viewModel.bioLoadError == nil &&
            viewModel.bio.contestantId == suggestion.id &&
            !viewModel.bio.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            hasCompetitionData
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.loading || (viewModel.bio.contestantId == 0 && viewModel.bioLoadError == nil) {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.bioLoadError {
                    ContentUnavailableView {
                        Label("Unable to Load Athlete", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try Again") {
                            Task {
                                await viewModel.getBio(for: suggestion.id)
                            }
                        }
                    }
                } else {
                    confirmationContent
                }
            }
            .background(Color.appBg)
            .navigationTitle("Confirm Athlete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task(id: suggestion.id) {
            await viewModel.getBio(for: suggestion.id)
        }
    }

    private var confirmationContent: some View {
        VStack(alignment: .leading, spacing: AppSpace.xl) {
            VStack(alignment: .leading, spacing: AppSpace.sm) {
                Text(viewModel.bio.name.isEmpty ? suggestion.term : viewModel.bio.name)
                    .font(.appCardTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPrimary)

                Text(
                    String(
                        format: NSLocalizedString("Athlete ID: %d", comment: ""),
                        suggestion.id
                    )
                )
                .font(.appCaption)
                .foregroundStyle(Color.appTertiary)

                if !viewModel.bio.hometown.isEmpty {
                    Label(viewModel.bio.hometown, systemImage: "mappin.and.ellipse")
                        .font(.appBody)
                        .foregroundStyle(Color.appSecondary)
                }

                Divider()

                if hasCompetitionData {
                    if !viewModel.bio.events.isEmpty {
                        Label(
                            viewModel.bio.events
                                .map(\.eventDisplay)
                                .sorted()
                                .joined(separator: ", "),
                            systemImage: "list.bullet"
                        )
                        .font(.appBody)
                        .foregroundStyle(Color.appSecondary)
                    }

                    Label(viewModel.bio.careerEarnings, systemImage: "dollarsign.circle")
                        .font(.appBody)
                        .foregroundStyle(Color.appSecondary)
                } else {
                    Label("No Competition Data", systemImage: "exclamationmark.triangle")
                        .font(.appBodyStrong)
                        .foregroundStyle(Color.appSecondary)

                    Text("This athlete record has no results, rankings, or earnings available. Select another matching record if one is listed.")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .appCardStyle()

            Spacer(minLength: 0)

            Button {
                onConfirm(viewModel.bio)
            } label: {
                Label("Add to Favorites", systemImage: "star.badge.plus")
                    .font(.appBodyStrong)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpace.md)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appSecondary)
            .disabled(!canConfirm)
        }
        .padding(AppSpace.xl)
    }
}
