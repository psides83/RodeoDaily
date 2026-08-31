import Foundation
import SwiftUI

@MainActor
final class PastChampionsApi: ObservableObject {
    @Published private(set) var state: LoadingState<[PastChampion]> = .idle([])

    let standingsServiceConfig = StandingsServiceConfig()

    var champions: [PastChampion] { state.value }
    var loading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }

    func load() async throws {
        guard !loading else { return }

        let request = try standingsServiceConfig.getPastChampionsUrl()

        state = .loading(champions)

        do {
            let decoded = try await APIClient.fetch([PastChampion].self, for: request)
            if decoded.isEmpty {
                state = .failed(decoded, message: "No champions available right now.")
            } else {
                state = .loaded(decoded)
            }
        } catch let apiError as APIClientError {
            let message = "Champions request failed: \(apiError.localizedDescription)"
            state = .failed(champions, message: message)
        } catch let decodingError as DecodingError {
            let message = Self.describeDecodingError(decodingError)
            state = .failed(champions, message: message)
        } catch {
            let message = "Unable to load champions: \(error.localizedDescription)"
            state = .failed(champions, message: message)
        }
    }

    private static func describeDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Unable to decode champions. Type mismatch for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Unable to decode champions. Missing value for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Unable to decode champions. Missing key '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Unable to decode champions. Data corrupted at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        @unknown default:
            return "Unable to decode champions: \(error.localizedDescription)"
        }
    }
}
