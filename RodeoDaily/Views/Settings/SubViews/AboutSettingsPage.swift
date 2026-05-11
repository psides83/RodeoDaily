import SwiftUI

struct AboutSettingsPage: View {
    var body: some View {
        Form {
            Section("Feedback") {
                Link(destination: URL(string: "mailto:thewaymediaco@gmail.com")!) {
                    Label("Submit Feedback", systemImage: "envelope")
                }
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
}
