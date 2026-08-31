import Foundation

struct PastChampion: Codable, Identifiable, Hashable {
    let id: String
    let year: Int
    let event: String
    let athlete: String
    let hometown: String
}
