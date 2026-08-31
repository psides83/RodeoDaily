import SwiftUI

struct PBJFeedHostView: View {
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
        .navigationTitle(NSLocalizedString("Rodeos", comment: ""))
        .task {
            guard !didInitialLoad else { return }
            didInitialLoad = true
            await api.load()
        }
    }
}

#Preview {
    NavigationStack {
        PBJFeedHostView()
    }
}
