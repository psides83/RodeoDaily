//import SwiftUI
//
//private struct DashboardLoader: View {
//    @State private var opacity = 0.22
//
//    var body: some View {
//        VStack(spacing: AppSpace.md) {
//            favoriteLeadersSkeleton
//            inProgressRodeosSkeleton
//        }
//        .onAppear {
//            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
//                opacity = 0.42
//            }
//        }
//    }
//
//    private var favoriteLeadersSkeleton: some View {
//        VStack(alignment: .leading, spacing: AppSpace.sm) {
//            HStack {
//                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                    .fill(Color.appPrimary.opacity(opacity))
//                    .frame(width: 140, height: 16)
//                Spacer()
//                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                    .fill(Color.appSecondary.opacity(opacity))
//                    .frame(width: 92, height: 12)
//            }
//
//            ForEach(0..<5, id: \.self) { _ in
//                HStack(spacing: 10) {
//                    RoundedRectangle(cornerRadius: 5, style: .continuous)
//                        .fill(Color.appSecondary.opacity(opacity))
//                        .frame(width: 28, height: 12)
//
//                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                        .fill(Color.appPrimary.opacity(opacity))
//                        .frame(width: 140, height: 12)
//
//                    Spacer()
//
//                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                        .fill(Color.appTertiary.opacity(opacity))
//                        .frame(width: 72, height: 10)
//                }
//            }
//        }
//        .appCardStyle()
//    }
//
//    private var inProgressRodeosSkeleton: some View {
//        VStack(alignment: .leading, spacing: AppSpace.sm) {
//            HStack {
//                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                    .fill(Color.appPrimary.opacity(opacity))
//                    .frame(width: 130, height: 16)
//                Spacer()
//                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                    .fill(Color.appSecondary.opacity(opacity))
//                    .frame(width: 80, height: 12)
//            }
//
//            ForEach(0..<2, id: \.self) { _ in
//                VStack(alignment: .leading, spacing: AppSpace.xs) {
//                    HStack {
//                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                            .fill(Color.appPrimary.opacity(opacity))
//                            .frame(width: 170, height: 14)
//                        Spacer()
//                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                            .fill(Color.appSecondary.opacity(opacity))
//                            .frame(width: 66, height: 10)
//                    }
//
//                    HStack {
//                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                            .fill(Color.appTertiary.opacity(opacity))
//                            .frame(width: 124, height: 10)
//                        Spacer()
//                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                            .fill(Color.appTertiary.opacity(opacity))
//                            .frame(width: 72, height: 10)
//                    }
//
//                    ForEach(0..<2, id: \.self) { _ in
//                        HStack(spacing: 8) {
//                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                                .fill(Color.appSecondary.opacity(opacity))
//                                .frame(width: 24, height: 10)
//                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                                .fill(Color.appPrimary.opacity(opacity))
//                                .frame(width: 130, height: 10)
//                            Spacer()
//                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
//                                .fill(Color.appTertiary.opacity(opacity))
//                                .frame(width: 40, height: 10)
//                        }
//                    }
//                }
//                .padding(.vertical, 2)
//            }
//        }
//        .appCardStyle()
//    }
//}
//
//struct DashboardView: View {
//    let openStandings: () -> Void
//    let openResults: () -> Void
//    let openRodeos: () -> Void
//    let openAthletes: () -> Void
//    let favoriteStandingsEvent: StandingsEvent
//    let favoriteResultsEvent: Events.CodingKeys
//    let standings: [Position]
//    let rodeos: [RodeoData]
//    let standingsLoading: Bool
//    let rodeosLoading: Bool
//    let widgetAthletes: [WidgetAthlete]
//    let applyFavoriteStandings: () -> Void
//    let applyFavoriteResults: () -> Void
//    @State private var rodeoSnapshots: [String: [Winner]] = [:]
//    @State private var loadingSnapshots = Set<String>()
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: AppSpace.md) {
//            if showSkeleton {
//                DashboardLoader()
//            } else {
//                favoriteEventLeadersCard
//                inProgressRodeosCard
//            }
//        }
//    }
//
//    private var showSkeleton: Bool {
//        (standingsLoading && standings.isEmpty) || (rodeosLoading && rodeos.isEmpty)
//    }
//
//    private var favoriteEventLeadersCard: some View {
//        VStack(alignment: .leading, spacing: AppSpace.sm) {
//            HStack {
//                Text(favoriteStandingsEvent.title)
//                    .font(.appBodyStrong)
//                    .foregroundColor(.appPrimary)
//                Spacer()
//                Button(NSLocalizedString("Open Standings", comment: "")) {
//                    applyFavoriteStandings()
//                }
//                .font(.caption)
//                .foregroundColor(.appSecondary)
//                .buttonStyle(.plain)
//            }
//
//            if standings.isEmpty {
//                Text(NSLocalizedString("No standings loaded yet for your favorite event.", comment: ""))
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//            } else {
//                ForEach(Array(standings.prefix(5)), id: \.id) { position in
//                    HStack(spacing: 10) {
//                        Text("#\(position.place)")
//                            .font(.caption.weight(.semibold))
//                            .foregroundColor(.appSecondary)
//                            .frame(width: 30, alignment: .leading)
//
//                        Text(position.name)
//                            .font(.caption.weight(.semibold))
//                            .foregroundColor(.appPrimary)
//                            .lineLimit(1)
//
//                        Spacer()
//
//                        Text(position.earnings.currencyABS)
//                            .font(.caption2)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//            }
//        }
//        .appCardStyle()
//    }
//
//    private var inProgressRodeosCard: some View {
//        VStack(alignment: .leading, spacing: AppSpace.sm) {
//            HStack {
//                Text(NSLocalizedString("In-Progress Rodeos", comment: ""))
//                    .font(.appBodyStrong)
//                    .foregroundColor(.appPrimary)
//                Spacer()
//                Button(NSLocalizedString("Open Results", comment: "")) {
//                    applyFavoriteResults()
//                }
//                .font(.caption)
//                .foregroundColor(.appSecondary)
//                .buttonStyle(.plain)
//            }
//
//            if inProgressRodeos.isEmpty {
//                Text(NSLocalizedString("No active rodeos found in current results feed.", comment: ""))
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//            } else {
//                ForEach(visibleInProgressRodeos, id: \.id) { rodeo in
//                    VStack(alignment: .leading, spacing: 4) {
//                        HStack {
//                            Text(rodeo.name)
//                                .font(.caption.weight(.semibold))
//                                .foregroundColor(.appPrimary)
//                                .lineLimit(1)
//                            Spacer()
//                            Text(rodeo.payout.currencyABS)
//                                .font(.caption2)
//                                .foregroundColor(.appSecondary)
//                        }
//                        HStack {
//                            Text(rodeo.location)
//                                .font(.caption2)
//                                .foregroundStyle(.secondary)
//                                .lineLimit(1)
//                            Spacer()
//                            Text("\(NSLocalizedString("Ends", comment: "")) \(formatDateNoYear(rodeo.endDate))")
//                                .font(.caption2)
//                                .foregroundStyle(.secondary)
//                        }
//
//                        let cacheKey = snapshotCacheKey(rodeoId: rodeo.id, event: favoriteResultsEvent)
//                        if loadingSnapshots.contains(cacheKey) {
//                            ProgressView()
//                                .scaleEffect(0.8)
//                                .padding(.top, 2)
//                        } else if let winners = rodeoSnapshots[cacheKey], !winners.isEmpty {
//                            ForEach(winners.prefix(3), id: \.id) { winner in
//                                HStack(spacing: 8) {
//                                    Text("#\(winner.placeDisplay)")
//                                        .font(.caption2.weight(.semibold))
//                                        .foregroundColor(.appSecondary)
//                                        .frame(width: 28, alignment: .leading)
//                                    Text(winner.name)
//                                        .font(.caption2.weight(.semibold))
//                                        .lineLimit(1)
//                                        .foregroundColor(.appPrimary)
//                                    Spacer()
//                                    Text(winner.result)
//                                        .font(.caption2)
//                                        .foregroundStyle(.secondary)
//                                }
//                            }
//                        } else {
//                            Text(NSLocalizedString("No live placements available yet.", comment: ""))
//                                .font(.caption2)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                    .padding(.vertical, 2)
//                }
//            }
//        }
//        .appCardStyle()
//        .task(id: snapshotTaskKey) {
//            await loadSnapshotsForVisibleRodeos()
//        }
//    }
//
//    private var inProgressRodeos: [RodeoData] {
//        return rodeos
//            .filter { $0.inProgress }
//            .sorted { lhs, rhs in
//                let left = parseDate(lhs.endDate) ?? .distantFuture
//                let right = parseDate(rhs.endDate) ?? .distantFuture
//                return left < right
//            }
//    }
//
//    private var visibleInProgressRodeos: [RodeoData] {
//        Array(inProgressRodeos.prefix(3))
//    }
//
//    private var snapshotTaskKey: String {
//        let ids = visibleInProgressRodeos.map { String($0.id) }.joined(separator: ",")
//        return "\(favoriteResultsEvent.rawValue)|\(ids)"
//    }
//
//    private func loadSnapshotsForVisibleRodeos() async {
//        for rodeo in visibleInProgressRodeos {
//            let cacheKey = snapshotCacheKey(rodeoId: rodeo.id, event: favoriteResultsEvent)
//            if rodeoSnapshots[cacheKey] != nil { continue }
//            if loadingSnapshots.contains(cacheKey) { continue }
//
//            await MainActor.run {
//                loadingSnapshots.insert(cacheKey)
//            }
//
//            let winners = await fetchRodeoSnapshot(
//                rodeoId: rodeo.id,
//                event: favoriteResultsEvent
//            )
//
//            await MainActor.run {
//                rodeoSnapshots[cacheKey] = winners
//                loadingSnapshots.remove(cacheKey)
//            }
//        }
//    }
//
//    private func snapshotCacheKey(rodeoId: Int, event: Events.CodingKeys) -> String {
//        "\(event.rawValue)-\(rodeoId)"
//    }
//
//    private func fetchRodeoSnapshot(
//        rodeoId: Int,
//        event: Events.CodingKeys
//    ) async -> [Winner] {
//        await withCheckedContinuation { continuation in
//            let api = ResultsApi()
//            Task {
//                await api.getWinners(rodeoId: rodeoId, event: event) { result in
//                    let firstPopulatedRound = result.rounds.first(where: { !$0.winners.isEmpty })
//                    let winners = firstPopulatedRound?.winners ?? []
//                    continuation.resume(returning: winners)
//                }
//            }
//        }
//    }
//
//    private func parseDate(_ value: String) -> Date? {
//        let formats = [
//            "yyyy-MM-dd'T'HH:mm:ss",
//            "yyyy-MM-dd'T'HH:mm:ss.SSS",
//            "yyyy-MM-dd"
//        ]
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone.current
//        for format in formats {
//            formatter.dateFormat = format
//            if let date = formatter.date(from: value) {
//                return date
//            }
//        }
//        return nil
//    }
//
//    private func formatDateNoYear(_ value: String) -> String {
//        guard let date = parseDate(value) else { return value }
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone.current
//        formatter.dateFormat = "MMM d"
//        return formatter.string(from: date)
//    }
//}
