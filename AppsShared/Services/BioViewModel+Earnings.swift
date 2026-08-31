import Foundation

extension BioViewModel {
    func stats(season: String) -> (
        seasonEarningsAndRank: (rank: String, earnings: String),
        bestGo: (rodeo: String, result: String),
        earningsGo: (rodeo: String, result: String, payout: String),
        earningRodeo: (rodeo:String, payout: String)
    ) {
        guard let selectedEvent else {
            return (
                ("Unranked", "No Earnings"),
                ("No Results", "-"),
                ("No Results", "-", "-"),
                ("No Results", "-")
            )
        }
        
        let seasonResults = bio.results
            .filter {
                $0.seasonMatches(season: season.int)
                &&
                $0.eventType == selectedEvent
                &&
                !$0.rodeoName.localizedCaseInsensitiveContains("national finals rodeo")
            }
        
        let resultsWithAve = bio.resultsAndAveragesCombined()
            .filter {
                $0.seasonMatches(season: season.int)
                &&
                $0.eventType == selectedEvent
                &&
                !$0.rodeoName.localizedCaseInsensitiveContains("national finals rodeo")
            }
        
        return (
            seasonEarningsAndRank(season: season),
            bestGo(results: seasonResults),
            earningsGo(results: seasonResults),
            earningsRodeo(results: resultsWithAve)
        )
    }
    
    func seasonEarningsAndRank(season: String) -> (rank: String, earnings: String) {
        let seasons = careerSeasons.filter({ $0.season == season })
        
        guard seasons.count > 0 else { return ("Unranked", "No Earnings") }
        
        let careerSeason = seasons[0]
        
        let rank = careerSeason.rank
        let earnings = careerSeason.earnings
        
        return (rank, earnings)
    }
    
    func bestGo(results: [BioResult]) -> (rodeo: String, result: String) {
        if selectedEvent == "BR" || selectedEvent == "BB" || selectedEvent == "SB" {
            if results.filter({ $0.score > 0 }).sorted(by: { $0.score < $1.score }).count > 0 {
                
                let best = results.sorted { $0.score > $1.score }[0]
                let rodeo = best.rodeoName
                let result = best.resultDisplay
                
                return (rodeo: rodeo, result: result)
            }
            
              return (rodeo: "No Reaults", result: "-")
          } else {
              if results.filter({ $0.time > 0 }).sorted(by: { $0.time < $1.time }).count > 0 {
                
                let best = results.filter({ $0.time > 0 }).sorted(by: { $0.time < $1.time })[0]
                let rodeo = best.rodeoName
                let result = best.resultDisplay
                
                return (rodeo: rodeo, result: result)
              }
              
              return (rodeo: "No Results", result: "-")
          }
      }
    
    func earningsGo(results: [BioResult]) -> (
        rodeo: String,
        result: String,
        payout: String
    ) {
        let highest = results.max(by: { $0.payoff < $1.payoff })
        
        guard let highest else { return (rodeo: "No Results", result: "-", payout: "-") }
        
        return (rodeo: highest.rodeoName, result: highest.resultDisplay, payout: highest.payoutDisplay)
    }
    
    func earningsRodeo(results: [BioResult]) -> (rodeo: String, payout: String)  {
        let highest = results
            .reduce(into: [Int: (name: String, total: Double)]()) { dict, result in
                dict[result.rodeoId, default: (result.rodeoName, 0)].total += result.payoff
            }
            .max(by: { $0.value.total < $1.value.total })
        
        guard let highest else { return (rodeo: "No Results", payout: "-") }
        
        return (rodeo: highest.value.name, payout: highest.value.total.currencyABS)
        
    }
    
    func nfrBestGo(season: Int) -> String? {
        guard let selectedEvent else { return nil }

        let seasonResults = nfrResults(forSeason: season, event: selectedEvent)
        if !seasonResults.isEmpty {
            if selectedEvent == "BR" || selectedEvent == "BB" || selectedEvent == "SB" {
                let best = seasonResults.sorted { $0.score > $1.score }[0]
                let result = best.resultDisplay
                
                return result
            } else {
                let timedResults = seasonResults
                    .filter { $0.time > 0 }
                    .sorted { $0.time < $1.time }
                
                guard let best = timedResults.first else { return nil }
                let result = best.resultDisplay
                
                return result
            }
        } else {
            return nil
        }
    }
    
    func monthlyEarnings(season: String) -> [(month: String, total: Double)] {
        guard let selectedEvent else { return [] }
        
        let seasonResults = bio.resultsAndAveragesCombined()
            .filter {
                $0.seasonMatches(season: season.int)
                &&
                $0.eventType == selectedEvent
            }
        
        // Build PRCA season month order: Oct -> Sep.
        let fiscalMonths = ["Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep"]
        
        // Filter for results belonging to this PRCA season window based on event end date.
        let filteredResults = seasonResults.filter { result in
            guard let date = result.endDate.rodeoDate else { return false }
            return prcaSeasonYear(for: date) == season.int
        }
        
        // Group by month abbreviation
        let grouped = filteredResults.reduce(into: [String: Double]()) { totals, result in
            guard let date = result.endDate.rodeoDate else { return }
            let month = date.monthAbreviated
            
            // Exclude NFR unless you want to count it separately
            if result.rodeoName.localizedCaseInsensitiveContains("national finals") {
                return
            }
            
            totals[month, default: 0] += result.payoff
        }
        
        // Fill missing months with 0
        let totals = fiscalMonths.map { month in
            (month, grouped[month] ?? 0)
        }
        
        return totals
    }
    
    func nfrEarnings(for season: String) -> String? {
        guard let selectedEvent else { return nil }

        let results = nfrResults(forSeason: season.int, event: selectedEvent)
        if results.isEmpty { return nil }
        
        return results.reduce(0) { $0 + $1.payoff }.currencyABS
    }

    private func nfrResults(forSeason season: Int, event: String) -> [BioResult] {
        let raw = bio.baseResults(for: season)
            .filter {
                $0.eventType == event
                && $0.rodeoName.localizedCaseInsensitiveContains("national finals")
            }

        // Some athlete payloads contain duplicated NFR rows with different RodeoResultId values.
        // Deduplicate by semantic result identity (round + result metrics) instead of ID.
        var deduped = [String: BioResult]()
        for result in raw {
            let round = result.round.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            let key = [
                result.seasonYear.string,
                result.eventType,
                result.rodeoId.string,
                round,
                String(format: "%.3f", result.payoff),
                String(format: "%.3f", result.time),
                String(format: "%.3f", result.score)
            ].joined(separator: "|")

            if deduped[key] == nil {
                deduped[key] = result
            }
        }

        return deduped.values.sorted { lhs, rhs in
            if lhs.endDate == rhs.endDate {
                return lhs.rodeoResultId < rhs.rodeoResultId
            }
            return lhs.endDate < rhs.endDate
        }
    }
    
    func prcaSeasonYear(for date: Date) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return month >= 10 ? year + 1 : year
    }
    

}
