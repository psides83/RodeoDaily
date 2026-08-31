//
//  ScheduleDetailView.swift
//  RodeoDaily
//
//  Created by Codex on 5/12/26.
//

import SwiftUI
import MapKit

struct RodeoScheduleDetailView: View {
    let rodeo: RodeoData

    @State private var daysheets = [ScheduleDaysheet]()
    @State private var daysheetsLoading = false
    @State private var daysheetsError: String?

    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var venueCoordinate: CLLocationCoordinate2D?
    @State private var resolvedVenueName = ""
    @State private var isLoadingVenueMap = false
    @State private var venueMapUnavailable = false
    @State private var isShowingFullMap = false

    private func displayDate(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix("0001-01-01") {
            return "TBD"
        }
        return raw.medium
    }

    private var dateRangeDisplay: String {
        let start = displayDate(rodeo.startDate)
        let end = displayDate(rodeo.endDate)

        if start == "TBD" && end == "TBD" {
            return "Dates TBD"
        }
        if start == end {
            return start
        }
        return "\(start) - \(end)"
    }

    private var mapSearchQuery: String {
        if rodeo.venueName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return rodeo.location
        }
        return "\(rodeo.venueName), \(rodeo.location)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.xl) {
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    HStack(alignment: .center, spacing: AppSpace.sm) {
                        Text(rodeo.name)
                            .font(.appSectionTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: AppSpace.xs)

                        if rodeo.inProgress {
                            Text("In Progress")
                                .font(.appCaptionStrong)
                                .foregroundColor(.orange)
                                .padding(.horizontal, AppSpace.sm)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.15), in: Capsule())
                        }
                    }

                    HStack(spacing: AppSpace.xs) {
                        Text(rodeo.location)
                            .font(.subheadline)
                            .foregroundColor(.appSecondary)
                        Circle()
                            .fill(Color.appSecondary)
                            .frame(width: 4, height: 4)
                        Text(dateRangeDisplay)
                            .font(.subheadline)
                            .foregroundColor(.appTertiary)
                    }

                    HStack(alignment: .center, spacing: AppSpace.sm) {
                        Text("Added Money: \(rodeo.payout.currencyABS)")
                            .font(.appMetricValue)
                            .foregroundColor(.appPrimary)

                        Spacer(minLength: AppSpace.xs)

                        if let tourTitle = rodeo.tourTitles.first, !tourTitle.isEmpty {
                            Text(tourTitle)
                                .font(.appCaptionStrong)
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, AppSpace.sm)
                                .padding(.vertical, 6)
                                .background(Color.appTertiary.opacity(0.15), in: Capsule())
                        }
                    }
                }
                .appCardStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text("Circuits")
                        .font(.appCardTitle)
                        .foregroundColor(.appPrimary)

                    if rodeo.circuitTitles.isEmpty {
                        Text("No circuit tags.")
                            .font(.appBody)
                            .foregroundColor(.appTertiary)
                    } else {
                        Text(rodeo.circuitTitles.joined(separator: ", "))
                            .font(.appBody)
                            .foregroundColor(.appPrimary)
                    }
                }
                .appCardStyle()

                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text(rodeo.venueName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Venue Map" : rodeo.venueName)
                        .font(.appCardTitle)
                        .foregroundColor(.appPrimary)

                    ZStack {
                        if venueMapUnavailable {
                            VStack(spacing: AppSpace.sm) {
                                Image(systemName: "mappin.slash")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.appTertiary)
                                Text("Venue could not be located")
                                    .font(.appBodyStrong)
                                    .foregroundColor(.appPrimary)
                                Text(rodeo.location)
                                    .font(.appCaption)
                                    .foregroundColor(.appTertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .background(Color.appBg)
                        } else {
                            Map(position: $mapPosition, interactionModes: [.zoom, .pan]) {
                                if let coordinate = venueCoordinate {
                                    Marker(resolvedVenueName, coordinate: coordinate)
                                        .tint(.red)
                                }
                            }
                            .mapStyle(.hybrid(elevation: .realistic))
                        }
                    }
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
                    )
                    .overlay {
                        if isLoadingVenueMap {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .fill(Color.appBg.opacity(0.72))
                                ProgressView("Loading map...")
                                    .font(.appCaption)
                            }
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if venueCoordinate != nil {
                            Button {
                                isShowingFullMap = true
                            } label: {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                                    .padding(10)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(10)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if venueCoordinate != nil {
                            Button {
                                recenterPreviewMap()
                            } label: {
                                Image(systemName: "location.north.line.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                                    .padding(10)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(10)
                        }
                    }

                    if !venueMapUnavailable {
                        Text("Preview map. Open full screen for full controls.")
                            .font(.appCaption)
                            .foregroundColor(.appTertiary)
                    }
                }
                .appCardStyle()

                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    Text("Daysheets")
                        .font(.appCardTitle)
                        .foregroundColor(.appPrimary)

                    if daysheetsLoading {
                        ProgressView("Loading daysheets...")
                    } else if let daysheetsError {
                        Text(daysheetsError)
                            .font(.appBody)
                            .foregroundColor(.red)
                    } else if !daysheets.isEmpty {
                        VStack(spacing: AppSpace.sm) {
                            ForEach(daysheets) { daysheet in
                                NavigationLink {
                                    DaysheetDetailView(rodeoName: rodeo.name, daysheet: daysheet)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(daysheet.roundsDisplay)
                                                .font(.appBodyStrong)
                                                .foregroundColor(.appPrimary)
                                                .multilineTextAlignment(.leading)
                                            Text(daysheet.startDisplay)
                                                .font(.appCaptionStrong)
                                                .foregroundColor(.appTertiary)
                                            Text("\(daysheet.eventNames.count) events")
                                                .font(.appCaption)
                                                .foregroundColor(.appSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.appSecondary)
                                    }
                                    .padding(AppSpace.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                            .fill(Color.appBg)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                            .stroke(Color.appTertiary.opacity(0.25), lineWidth: AppStroke.hairline)
                                    )
                                }
                            }
                        }
                    } else if rodeo.hasDaysheets {
                        Text("No daysheets returned yet for this rodeo.")
                            .font(.appBody)
                            .foregroundColor(.appTertiary)
                    } else {
                        Text("No daysheets listed for this rodeo.")
                            .font(.appBody)
                            .foregroundColor(.appTertiary)
                    }
                }
                .appCardStyle()

                if let website = rodeo.websiteUrl,
                   let url = URL(string: website),
                   !website.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Link(destination: url) {
                        Label("Open Rodeo Website", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.loadingButton(false))
                    .padding(.top, AppSpace.xs)
                }

                BannerAd(placement: .scheduleDetailBottom)
            }
            .padding()
        }
        .navigationTitle("Rodeo Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.appBg)
        .onAppear {
            AnalyticsService.shared.track(.rodeoDetailViewed(source: "schedule", rodeoID: rodeo.id))
        }
        .task {
            await loadDaysheetsIfNeeded()
            loadVenueMap()
        }
        .fullScreenCover(isPresented: $isShowingFullMap) {
            NavigationStack {
                VenueMapView(
                    city: rodeo.location,
                    venue: rodeo.venueName,
                    initialCoordinate: venueCoordinate ?? rodeo.coordinate,
                    initialVenueName: resolvedVenueName.isEmpty ? nil : resolvedVenueName
                )
                    .navigationTitle(rodeo.venueName.isEmpty ? rodeo.location : rodeo.venueName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isShowingFullMap = false
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpace.sm) {
            Text(label)
                .font(.appCaptionStrong)
                .foregroundColor(.appTertiary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.appBody)
                .foregroundColor(.appPrimary)
            Spacer()
        }
    }

    private func loadDaysheetsIfNeeded() async {
        guard rodeo.hasDaysheets else { return }
        daysheetsLoading = true
        defer { daysheetsLoading = false }

        do {
            let url = ApiUrls().rodeoDaysheetsUrl(for: rodeo.id)
            let response = try await APIClient.fetch(DaysheetResponse.self, from: url)
            daysheets = makeDaysheets(from: response)
            daysheetsError = nil
        } catch {
            daysheetsError = "Unable to load daysheets right now."
        }
    }

    private func makeDaysheets(from response: DaysheetResponse) -> [ScheduleDaysheet] {
        let merged = response.data.map { startDateKey, performances in
            ScheduleDaysheet(startDateKey: startDateKey, performances: performances)
        }

        return merged.sorted { lhs, rhs in
            if lhs.sortDate == rhs.sortDate {
                return lhs.rounds.count < rhs.rounds.count
            }
            return lhs.sortDate < rhs.sortDate
        }
    }

    private func loadVenueMap() {
        if let coordinate = rodeo.coordinate {
            venueCoordinate = coordinate
            venueMapUnavailable = false
            resolvedVenueName = rodeo.venueName.isEmpty ? rodeo.location : rodeo.venueName
            setPreviewMapPosition(coordinate)
            return
        }

        searchForVenue()
    }

    private func searchForVenue() {
        isLoadingVenueMap = true
        venueMapUnavailable = false
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = mapSearchQuery

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let item = response?.mapItems.first else {
                venueCoordinate = nil
                venueMapUnavailable = true
                isLoadingVenueMap = false
                return
            }

            let coord = item.placemark.coordinate
            venueCoordinate = coord
            venueMapUnavailable = false
            resolvedVenueName = item.name ?? (rodeo.venueName.isEmpty ? rodeo.location : rodeo.venueName)

            setPreviewMapPosition(coord)
            isLoadingVenueMap = false
        }
    }

    private func setPreviewMapPosition(_ coordinate: CLLocationCoordinate2D) {
        withAnimation {
            mapPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
                )
            )
        }
    }

    private func recenterPreviewMap() {
        guard let coordinate = venueCoordinate else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            mapPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
                )
            )
        }
    }
}
