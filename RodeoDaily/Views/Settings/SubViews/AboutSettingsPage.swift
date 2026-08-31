import SwiftUI

struct AboutSettingsPage: View {
    @ObservedObject private var adMobService = AdMobService.shared

    var body: some View {
        Form {
            Section("Feedback") {
                Link(destination: URL(string: "mailto:thewaymediaco@gmail.com")!) {
                    Label("Submit Feedback", systemImage: "envelope")
                }
            }

            if adMobService.isPrivacyOptionsRequired {
                Section("Privacy") {
                    Button {
                        adMobService.presentPrivacyOptions()
                    } label: {
                        Label("Manage Ad Privacy Choices", systemImage: "hand.raised")
                    }
                }
            }
            
            Section("Privacy and Support") {
                aboutLinkRow(
                    title: "Privacy Policy",
                    subtitle: "View full privacy policy",
                    systemImage: "checkmark.shield",
                    url: "https://prorodeoresults.app/privacy"
                )

                aboutLinkRow(
                    title: "Support",
                    subtitle: "Get help, report issues, or contact support about privacy questions",
                    systemImage: "questionmark.circle",
                    url: "https://prorodeoresults.app/support"
                )
            }

            Section("Data Sources") {
                Link(
                    "Results data provided by the PRCA",
                    destination: URL(string: "https://prorodeo.com")!
                )

                Link(
                    "Standings data provided by the PRCA",
                    destination: URL(string: "https://prorodeo.com")!
                )

                Link(destination: URL(string: "https://wpra.com")!) {
                    Text("Barrel Racing and Breakaway standings data provided by the WPRA")
                }
            }

            Section("Credits") {
                Link(
                    "Cowboy Icon provided by IconScout",
                    destination: URL(string: "https://iconscout.com/icons/cowboy")!
                )
            }
        }
        .tint(.appPrimary)
        .navigationTitle("About")
    }

    private func aboutLinkRow(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        systemImage: String,
        url: String
    ) -> some View {
        Link(destination: URL(string: url)!) {
            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}
