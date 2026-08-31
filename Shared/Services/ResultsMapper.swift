//
//  ResultsMapper.swift
//  RodeoDaily
//
//  Created by Codex on 5/15/26.
//

import Foundation

enum ResultsMapper {
    private static let maxDisplayedWinners = 20

    static func rodeoAndRounds(
        from response: RodeoResults,
        event: Events.CodingKeys
    ) -> (rodeo: Datum, rounds: [String: [Round]])? {
        guard let rodeo = response.data?.first,
              let events = rodeo.events,
              let rounds = rounds(from: events, event: event)
        else {
            return nil
        }

        return (rodeo, rounds)
    }

    static func map(
        rodeoId: Int,
        rodeo: Datum,
        rounds: [String: [Round]],
        event: Events.CodingKeys
    ) -> RodeoResult {
        let roundWinners = rounds.map { round in
            mapRound(id: round.key, rounds: round.value, event: event)
        }

        return RodeoResult(
            id: rodeoId,
            city: rodeo.city,
            state: rodeo.state,
            name: rodeo.name,
            rounds: sortRoundWinners(roundWinners)
        )
    }

    static func map(
        rodeoId: Int,
        response: RodeoResults,
        event: Events.CodingKeys
    ) -> RodeoResult? {
        guard let resultData = rodeoAndRounds(from: response, event: event) else {
            return nil
        }

        return map(
            rodeoId: rodeoId,
            rodeo: resultData.rodeo,
            rounds: resultData.rounds,
            event: event
        )
    }

    private static func mapRound(
        id: String,
        rounds: [Round],
        event: Events.CodingKeys
    ) -> RoundWinners {
        let contestantRounds = rounds.filter { !$0.contestant.isEmpty }

        let hasPayouts = contestantRounds.contains { $0.payoff != 0 }
        let paidRoundWinners = contestantRounds
            .unique { $0.contestant[0].id }
            .sorted { sortRounds(lhs: $0, rhs: $1, event: event) }
            .prefix(maxDisplayedWinners)
            .enumerated()
            .compactMap { index, winner in
                mapWinner(winner, id: id, event: event, fallbackIndex: index)
            }

        if hasPayouts, !paidRoundWinners.isEmpty {
            return RoundWinners(
                id: id.int,
                round: paidRoundWinners.first?.roundLabel ?? "1",
                winners: paidRoundWinners
            )
        }

        let currentRound = rounds
            .map { $0.numberScores ?? 0 }
            .max()

        let leaders = contestantRounds
            .unique { $0.contestant[0].id }
            .filter { $0.time != 0 || $0.score != 0 }
            .filter { round in
                guard id.int >= 555 else { return true }
                return round.numberScores == currentRound || round.numberScores == 0
            }
            .sorted { sortRounds(lhs: $0, rhs: $1, event: event) }
            .prefix(maxDisplayedWinners)
            .enumerated()
            .compactMap { index, winner in
                mapWinner(winner, id: id, event: event, fallbackIndex: index)
            }

        return RoundWinners(
            id: id.int,
            round: leaders.first?.roundLabel ?? "1",
            winners: leaders
        )
    }

    private static func mapWinner(
        _ winner: Round,
        id: String,
        event: Events.CodingKeys,
        fallbackIndex: Int? = nil
    ) -> Winner? {
        guard let contestant = winner.contestant.first else {
            return nil
        }

        let winnerId = "\(id)\(contestant.id)"

        return Winner(
            id: winnerId.int,
            contestantId: contestant.id,
            roundLabel: winner.goRoundLabel,
            name: contestant.name,
            hometown: contestant.hometown,
            imageUrl: contestant.imageUrl,
            payoff: winner.payoff,
            time: winner.time,
            score: winner.score,
            place: fallbackIndex.map { setPlacement(for: event, from: winner.place, at: $0) } ?? winner.place,
            round: winner.goRound,
            teamId: winner.teamId,
            numberScores: winner.numberScores ?? 0
        )
    }

    private static func rounds(
        from events: Events,
        event: Events.CodingKeys
    ) -> [String: [Round]]? {
        switch event {
        case .bb:
            return events.bb
        case .sw:
            return events.sw
        case .sb:
            return events.sb
        case .td:
            return events.td
        case .gb:
            return events.gb
        case .br:
            return events.br
        case .tr:
            return events.tr
        case .lb:
            return events.lb
        case .sr:
            return events.sr
        }
    }

    private static func sortRoundWinners(_ rounds: [RoundWinners]) -> [RoundWinners] {
        rounds.sorted {
            $0.id < 555 || $1.id < 555 ? $0.id < $1.id : $0.id > $1.id
        }
    }

    private static func sortRounds(
        lhs: Round,
        rhs: Round,
        event: Events.CodingKeys
    ) -> Bool {
        let leftPlace = placementSortValue(lhs.place)
        let rightPlace = placementSortValue(rhs.place)

        if leftPlace != rightPlace {
            return leftPlace < rightPlace
        }

        if event.isRoughStock {
            return lhs.score > rhs.score
        }

        return lhs.time < rhs.time
    }

    private static func setPlacement(
        for event: Events.CodingKeys,
        from place: Int,
        at index: Int
    ) -> Int {
        if place > 0 { return place }
        return event == .tr ? (index / 2) + 1 : index + 1
    }

    private static func placementSortValue(_ place: Int) -> Int {
        place > 0 ? place : Int.max
    }
}
