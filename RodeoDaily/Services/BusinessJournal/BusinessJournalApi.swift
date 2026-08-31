import Foundation

@MainActor
final class BusinessJournalApi: ObservableObject {
    @Published private(set) var state: LoadingState<[BusinessJournalFeedItem]> = .idle([])

    private let feedURL = URL(string: "https://psides83.github.io/pbj-scraper/pbj-detailed.json")

    var items: [BusinessJournalFeedItem] { state.value }
    var loading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }

    func load() async {
        guard !loading else { return }
        guard let feedURL else {
            state = .failed(items, message: "Invalid BusinessJournal listings URL.")
            return
        }

        state = .loading(items)

        do {
            let data = try await APIClient.data(from: feedURL)
            let decoder = JSONDecoder()
            let parsed: [BusinessJournalFeedItem]
            if let typedResponse = try? decoder.decode(BusinessJournalFeedResponse.self, from: data) {
                parsed = BusinessJournalListingsParser.parse(response: typedResponse)
            } else {
                let json = try JSONSerialization.jsonObject(with: data)
                parsed = BusinessJournalListingsParser.parse(jsonObject: json)
            }

            if parsed.isEmpty {
                state = .failed(parsed, message: "No rodeos feed items available right now.")
            } else {
                state = .loaded(parsed)
            }
        } catch let apiError as APIClientError {
            state = .failed(items, message: "Rodeos feed request failed: \(apiError.localizedDescription)")
        } catch {
            state = .failed(items, message: "Unable to load rodeos feed: \(error.localizedDescription)")
        }
    }
}
