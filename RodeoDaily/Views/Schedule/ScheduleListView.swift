//
//  ScheduleListView.swift
//  RodeoDaily
//
//  Created by Codex on 2/19/26.
//

import SwiftUI

struct ScheduleListView: View {
    let rodeos: [RodeoData]
    let loading: Bool
    
    @Binding var index: Int
    @Binding var dateRange: Set<DateComponents>
    
    @State private var dateRangeDisplay = ""
    @State private var isShowingCalendar = false
    @State private var hasAttemptedLoad = false
    
    var body: some View {
        let sortedRodeos = upcomingRodeos
        
        VStack(alignment: .leading, spacing: 16) {
            listHeader
            
            if dateRange.count > 1 {
                FilterChip(dateRangeDisplay: dateRangeDisplay, dateRange: $dateRange)
            }
            
            if loading || (rodeos.isEmpty && !hasAttemptedLoad) {
                RodeosLoader()
            } else if !sortedRodeos.isEmpty {
                LazyVStack(spacing: 0) {
                    ForEach(sortedRodeos.indices, id: \.self) { listIndex in
                        let rodeo = sortedRodeos[listIndex]
                        
                        NavigationLink {
                            VenueMapView(city: rodeo.location, venue: rodeo.venueName)
                        } label: {
                            ScheduleCell(rodeo: rodeo)
                        }
                        
                        if listIndex != sortedRodeos.count - 1 {
                            Divider()
                                .overlay(Color.appTertiary)
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Upcoming Rodeos", systemImage: "calendar.badge.exclamationmark")
                        .foregroundColor(.appPrimary)
                } description: {
                    Text("There are no current or upcoming rodeos for this filter.")
                        .foregroundColor(.appPrimary)
                }
            }
            
            LoadMoreButton(loading: loading) {
                index += 1
            }
            
            BannerAd(style: .mediumRectangle)
        }
        .padding(.bottom)
        .onChange(of: isShowingCalendar) { old, newValue in
            if !newValue && dateRange.count < 2 {
                dateRange.removeAll()
            }
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker(
                dateRange: $dateRange,
                dateRangeDisplay: $dateRangeDisplay,
                isShowingCalendar: $isShowingCalendar
            )
        }
        .onAppear {
            if !rodeos.isEmpty {
                hasAttemptedLoad = true
            }
            logScheduleCounts()
        }
        .onChange(of: loading) { _, isLoading in
            if !isLoading {
                hasAttemptedLoad = true
            }
        }
        .onChange(of: rodeos.count) { _, _ in
            logScheduleCounts()
        }
    }
    
    var upcomingRodeos: [RodeoData] {
        let startOfToday = Calendar.current.startOfDay(for: Date())

        return rodeos.filter { rodeo in
            let parsedEnd = parseDate(rodeo.endDate)
            let parsedStart = parseDate(rodeo.startDate)
            
            switch (parsedStart, parsedEnd) {
            case let (start?, end?):
                // Some feeds have inconsistent EndDate values; keep upcoming if either date is upcoming.
                return start >= startOfToday || end >= startOfToday
            case let (start?, nil):
                return start >= startOfToday
            case let (nil, end?):
                return end >= startOfToday
            case (nil, nil):
                // Keep rendering instead of dropping all rows when upstream date format shifts.
                return true
            }
        }
        .sorted { first, second in
            let firstDate = parseDate(first.startDate) ?? parseDate(first.endDate) ?? .distantFuture
            let secondDate = parseDate(second.startDate) ?? parseDate(second.endDate) ?? .distantFuture
            return firstDate < secondDate
        }
    }

    func parseDate(_ dateString: String) -> Date? {
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
    
    private func logScheduleCounts() {
        let upcoming = upcomingRodeos
        print("Schedule UI - fetched: \(rodeos.count), upcoming: \(upcoming.count)")
        if let first = rodeos.first {
            print("Schedule UI sample dates - start: \(first.startDate), end: \(first.endDate)")
        }
    }
    
    var listHeader: some View {
        HStack(alignment: .top, spacing: 22) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Rodeo")
                    .foregroundColor(.appPrimary)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Schedule")
                    .foregroundColor(.appSecondary)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button {
                isShowingCalendar = true
            } label: {
                VStack {
                    Image.calendar
                        .foregroundColor(.appPrimary)
                        .imageScale(.large)
                    
                    Text("Dates")
                        .font(.caption)
                        .foregroundColor(.appSecondary)
                }
            }
            .buttonStyle(.clearButton)
        }
    }
}

struct ScheduleCell: View {
    let rodeo: RodeoData
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(rodeo.name)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.appPrimary)
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Text(rodeo.location)
                        .font(.subheadline)
                    
                    Circle()
                        .fill(Color.appSecondary)
                        .frame(width: 4, height: 4)
                    
                    Text(rodeo.startDate.medium)
                        .font(.subheadline)
                        .foregroundColor(.appTertiary)
                }
                
                if !rodeo.venueName.isEmpty {
                    Text(rodeo.venueName)
                        .font(.caption)
                        .foregroundColor(.appTertiary)
                }
            }
            
            Spacer()
            
            Image(systemName: "map")
                .foregroundColor(.appSecondary)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.appSecondary)
        }
        .padding(.top, 8)
    }
}

#Preview {
    ContentView()
}
