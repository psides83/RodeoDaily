import SwiftUI

private struct MorePBJFeedHostView: View {
    @StateObject private var api = PBJFeedApi()
    @State private var searchText = ""
    @State private var didInitialLoad = false

    var body: some View {
        PBJFeedView(
            items: api.items,
            loading: api.loading,
            errorMessage: api.errorMessage,
            searchText: searchText
        ) {
            await api.load()
        }
        .task {
            guard !didInitialLoad else { return }
            didInitialLoad = true
            await api.load()
        }
    }
}

struct MoreView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.md) {
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(NSLocalizedString("More Features", comment: ""))
                    .font(.appSectionTitle)
                    .foregroundColor(.appPrimary)
                    .fontWeight(.bold)
            }
            .appCardStyle()

            NavigationLink {
                MorePBJFeedHostView()
            } label: {
                sectionRow(
                    symbol: "newspaper",
                    title: NSLocalizedString("Rodeo Listings", comment: ""),
                    subtitle: NSLocalizedString("Rodeo listings and details", comment: "")
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                AthletesView(searchText: "")
            } label: {
                sectionRow(
                    symbol: "person.3",
                    title: NSLocalizedString("Favorite Athletes", comment: ""),
                    subtitle: NSLocalizedString("Browse your selected favorite athlete bios", comment: "")
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                PastChampionsListView()
            } label: {
                sectionRow(
                    symbol: "rosette",
                    title: NSLocalizedString("Past World Champions", comment: ""),
                    subtitle: NSLocalizedString("Historic PRCA world champions", comment: "")
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                SettingsView()
            } label: {
                sectionRow(
                    symbol: "gearshape",
                    title: NSLocalizedString("Settings", comment: ""),
                    subtitle: NSLocalizedString("Preferences and app info", comment: "")
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func sectionRow(symbol: String, title: String, subtitle: String) -> some View {
        HStack(spacing: AppSpace.sm) {
            Image(systemName: symbol)
                .font(.headline)
                .frame(width: 28)
                .foregroundColor(.appSecondary)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .appCardStyle()
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}
