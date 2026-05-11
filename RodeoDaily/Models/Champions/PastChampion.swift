import Foundation

struct PastChampion: Codable, Identifiable, Hashable {
    let year: String
    let event: String
    let athlete: String
    let hometown: String?

    var id: String {
        "\(year)-\(event)-\(athlete)"
    }

    var yearValue: Int {
        Int(year) ?? 0
    }
}
