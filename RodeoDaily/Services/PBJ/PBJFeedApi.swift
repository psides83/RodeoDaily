import Foundation

@MainActor
final class PBJFeedApi: ObservableObject {
    @Published private(set) var items: [PBJFeedItem] = []
    @Published private(set) var loading = false
    @Published private(set) var errorMessage: String?

    private let feedURL = URL(string: "https://psides83.github.io/pbj-scraper/pbj-detailed.json")

    func load() async {
        guard !loading else { return }
        guard let feedURL else {
            errorMessage = "Invalid PBJ feed URL."
            return
        }

        loading = true
        defer { loading = false }

        do {
            let (data, response) = try await URLSession.shared.data(from: feedURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                errorMessage = "Rodeos feed request failed (\(status))."
                return
            }

            let decoder = JSONDecoder()
            let parsed: [PBJFeedItem]
            if let typedResponse = try? decoder.decode(PBJFeedResponse.self, from: data) {
                parsed = PBJFeedParser.parse(response: typedResponse)
            } else {
                let json = try JSONSerialization.jsonObject(with: data)
                parsed = PBJFeedParser.parse(jsonObject: json)
            }

            items = parsed
            errorMessage = parsed.isEmpty ? "No rodeos feed items available right now." : nil
        } catch {
            errorMessage = "Unable to load rodeos feed: \(error.localizedDescription)"
        }
    }
}
