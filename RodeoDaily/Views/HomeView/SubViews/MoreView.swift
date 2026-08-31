import SwiftUI

private struct MoreBusinessJournalListingsHostView: View {
    @StateObject private var api = BusinessJournalApi()
    @State private var searchText = ""
    @State private var didInitialLoad = false

    var body: some View {
        BusinessJournalListingsView(
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
                AthletesView(searchText: "")
            } label: {
                sectionRow(
                    customImage: .cowboy,
                    title: NSLocalizedString("Favorite Athletes", comment: ""),
                    subtitle: NSLocalizedString("Browse your selected favorite athlete bios", comment: "")
                )
            }
            .buttonStyle(.plain)

//            NavigationLink {
//                NFRStandingsView()
//            } label: {
//                sectionRow(
//                    symbol: "trophy",
//                    title: NSLocalizedString("NFR Standings", comment: ""),
//                    subtitle: NSLocalizedString("Round-by-round NFR average rankings", comment: "")
//                )
//            }
//            .buttonStyle(.plain)

            NavigationLink {
                MoreBusinessJournalListingsHostView()
            } label: {
                sectionRow(
                    symbol: "newspaper",
                    title: NSLocalizedString("Rodeo Listings", comment: ""),
                    subtitle: NSLocalizedString("Rodeo listings and details", comment: "")
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
        sectionRow(icon: Image(systemName: symbol), title: title, subtitle: subtitle)
    }

    private func sectionRow(customImage: Image, title: String, subtitle: String) -> some View {
        sectionRow(icon: customImage, title: title, subtitle: subtitle)
    }

    private func sectionRow(icon: Image, title: String, subtitle: String) -> some View {
        HStack(spacing: AppSpace.sm) {
            icon
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 28, height: 28)
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
