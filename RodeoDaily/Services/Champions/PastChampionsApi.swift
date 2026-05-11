import Foundation

@MainActor
final class PastChampionsApi: ObservableObject {
    @Published private(set) var champions: [PastChampion] = []
    @Published private(set) var loading = false
    @Published private(set) var errorMessage: String?

    private let feedURL = URL(string: "https://psides83.github.io/prca-history-records/past-champions.json")

    func load() async {
        guard !loading else { return }
        guard let feedURL else {
            errorMessage = "Invalid champions feed URL."
            return
        }

        loading = true
        defer { loading = false }

        do {
            let (data, response) = try await URLSession.shared.data(from: feedURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                errorMessage = "Champions feed request failed (\(status))."
                return
            }

            let decoded = try JSONDecoder().decode([PastChampion].self, from: data)
            champions = decoded
            errorMessage = decoded.isEmpty ? "No champions available right now." : nil
        } catch {
            errorMessage = "Unable to load champions: \(error.localizedDescription)"
        }
    }
}
