//
//  RodeoScheduleApi.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/2/23.
//

import Foundation
import SwiftUI

class RodeoScheduleApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var rodeos = [RodeoData]()
    @Published var loading = false
    
    func getRodeos(index: Int, searchText: String, dateParams: String, _ completionHandler: @escaping () -> Void) async {
        let candidateUrls = apiUrls.rodeoScheduleCandidateUrls(with: index, searchText: searchText, dateParams: dateParams)
        var loadedData: [RodeoData] = []
        var bestUpcomingData: [RodeoData] = []
        var lastError: Error?
        
        for url in candidateUrls {
            do {
                let data = try await APIService.fetchRodeos(from: url).data
                
                if !data.isEmpty {
                    // Keep first non-empty as fallback, but prefer responses with upcoming rodeos.
                    if loadedData.isEmpty {
                        loadedData = data
                    }
                    
                    let upcomingCount = data.filter { isUpcoming($0) }.count
                    if upcomingCount > bestUpcomingData.count {
                        bestUpcomingData = data
                    }
                }
            } catch {
                lastError = error
            }
        }
        
        let finalData = bestUpcomingData.isEmpty ? loadedData : bestUpcomingData
        
        DispatchQueue.main.async {
            guard !finalData.isEmpty else {
                print("no rodeos")
                if let lastError {
                    print("Schedule decode/request error:", lastError.localizedDescription)
                }
                if index == 1 {
                    self.rodeos = []
                }
                return completionHandler()
            }
            
            print(finalData.map { rodeo in rodeo.name })
            
            if index > 1 {
                self.rodeos.append(contentsOf: finalData)
                completionHandler()
            } else {
                self.rodeos = finalData
                completionHandler()
            }
        }
    }

    private func isUpcoming(_ rodeo: RodeoData) -> Bool {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startDate = parseDate(rodeo.startDate)
        let endDate = parseDate(rodeo.endDate)
        
        switch (startDate, endDate) {
        case let (start?, end?):
            return start >= startOfToday || end >= startOfToday
        case let (start?, nil):
            return start >= startOfToday
        case let (nil, end?):
            return end >= startOfToday
        case (nil, nil):
            return false
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let raw = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let parsed = isoFormatter.date(from: raw) {
            return parsed
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let parsed = isoFormatter.date(from: raw) {
            return parsed
        }

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd",
            "MM/d/yyyy"
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        for format in formats {
            formatter.dateFormat = format
            if let parsed = formatter.date(from: raw) {
                return parsed
            }
        }

        return nil
    }
    
    func loadRodeos(event: Events.CodingKeys, index: Int, searchText: String, dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        // if index == 1 {
        //     DispatchQueue.main.async {
        //         self.removeAllResults()
        //     }
        // }
        
        await getRodeos(index: index, searchText: searchText, dateParams: dateParams) {
            
            print(self.rodeos.count)
            
            self.endLoading()
        }
    }
    
    func searchRodeos(for event: Events.CodingKeys,by searchText: String, in dateParams: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        DispatchQueue.main.async {
            self.removeAllResults()
        }
        
        await getRodeos(index: 1, searchText: searchText, dateParams: dateParams) {
            
            self.endLoading()
        }
    }
    
    func loadRodeos(for event: Events.CodingKeys, in dateParams: String, with searchText: String, _ completionHandler: () -> Void) async {
        setLoading()
        
        DispatchQueue.main.async {
            self.removeAllResults()
        }
        
        await getRodeos(index: 1, searchText: searchText, dateParams: dateParams) {
            
            self.endLoading()
        }
    }
    
    func removeAllResults() {
        DispatchQueue.main.async {
            self.rodeos.removeAll()
        }
    }
    
    func setLoading() {
        DispatchQueue.main.async {
            self.loading = true
        }
    }
    
    func endLoading() {
        DispatchQueue.main.async {
            self.loading = false
            print("loading ended")
        }
    }
}
