//
//  ScheduleMapView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 11/10/25.
//

import SwiftUI
import MapKit
import UIKit

struct VenueMapView: View {
    enum MapMode: String, CaseIterable, Identifiable {
        case explore = "Explore"
        case driving = "Driving"
        case transit = "Transit"
        case satellite = "Satellite"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .explore: return "map"
            case .driving: return "car.fill"
            case .transit: return "tram.fill"
            case .satellite: return "globe.americas.fill"
            }
        }
    }

    @State private var position: MapCameraPosition = .automatic
    @State private var venueCoordinate: CLLocationCoordinate2D?
    @State private var venueName: String = ""
    @State private var venueMapUnavailable = false

    @State private var mode: MapMode = .satellite
    @State private var isShowingModePanel = false

    @State private var currentHeading: CLLocationDirection = 0
    @State private var currentPitch: CGFloat = 0
    @State private var currentDistance: CLLocationDistance = 9000
    @State private var currentCenter: CLLocationCoordinate2D?

    // UI-only toggles for now; can be wired to full style config later.
    @State private var isTrafficEnabled = false
    @State private var isLabelsEnabled = true

    let city: String
    let venue: String
    let initialCoordinate: CLLocationCoordinate2D?
    let initialVenueName: String?

    init(
        city: String,
        venue: String,
        initialCoordinate: CLLocationCoordinate2D? = nil,
        initialVenueName: String? = nil
    ) {
        self.city = city
        self.venue = venue
        self.initialCoordinate = initialCoordinate
        self.initialVenueName = initialVenueName
    }

    private let controlSize: CGFloat = 56
    private let controlSpacing: CGFloat = 12
    private let mapsButtonHeight: CGFloat = 40

    private var isIn3D: Bool {
        currentPitch >= 10
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if venueMapUnavailable {
                    VStack(spacing: AppSpace.sm) {
                        Image(systemName: "mappin.slash")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundColor(.appTertiary)
                        Text("Venue could not be located")
                            .font(.appSectionTitle)
                            .foregroundColor(.appPrimary)
                        Text(venue.isEmpty ? city : "\(venue), \(city)")
                            .font(.appBody)
                            .foregroundColor(.appTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBg)
                } else {
                    Map(position: $position, interactionModes: [.zoom, .pan, .pitch, .rotate]) {
                        if let coordinate = venueCoordinate {
                            Marker(venueName, coordinate: coordinate)
                                .tint(.red)
                        }
                    }
                    .mapStyle(mapStyle)
                    .mapControlVisibility(.hidden)
                    .onMapCameraChange(frequency: .continuous) { context in
                        currentHeading = context.camera.heading
                        currentPitch = context.camera.pitch
                        currentDistance = context.camera.distance
                        currentCenter = context.camera.centerCoordinate
                    }
                }

                rightControls(proxy: proxy)
                openInMapsButton(proxy: proxy)

                if isShowingModePanel {
                    modePanel(proxy: proxy)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isShowingModePanel)
            .onAppear {
                loadVenue()
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func rightControls(proxy: GeometryProxy) -> some View {
        if !isShowingModePanel && !venueMapUnavailable {
            let stackHeight = (controlSize * 4) + (controlSpacing * 2)
            let bottomInset = proxy.safeAreaInsets.bottom + mapsButtonHeight + 26
            let minTop = proxy.safeAreaInsets.top + 90
            let candidateBottomY = proxy.size.height - bottomInset - (stackHeight / 2)
            let centerY = max(minTop + (stackHeight / 2), candidateBottomY)

            VStack(spacing: 12) {
                VStack(spacing: 0) {
                    Button {
                        isShowingModePanel = true
                    } label: {
                        Image(systemName: "globe.americas.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                    }

                    Divider()
                        .overlay(Color.white.opacity(0.2))
                        .frame(width: controlSize - 20)

                    Button {
                        togglePitch()
                    } label: {
                        Text(isIn3D ? "2D" : "3D")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .contentTransition(.numericText())
                    }

                    Divider()
                        .overlay(Color.white.opacity(0.2))
                        .frame(width: controlSize - 20)

                    Button {
                        recenterToVenue()
                    } label: {
                        Image(systemName: "location.north.line.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                    }
                }
                .frame(width: controlSize)
                .background(Color.black.opacity(0.72), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                Button {
                    alignMapNorth()
                } label: {
                    Image(systemName: "location.north.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(currentHeading))
                        .frame(width: 56, height: 56)
                        .background(Color.black.opacity(0.72), in: Circle())
                }
            }
            .padding(.trailing, 14)
            .position(x: proxy.size.width - 14 - (controlSize / 2), y: centerY)
            .animation(.easeInOut(duration: 0.2), value: isIn3D)
            .zIndex(2)
        }
    }

    @ViewBuilder
    private func openInMapsButton(proxy: GeometryProxy) -> some View {
        if !isShowingModePanel && !venueMapUnavailable {
            Button {
                openInAppleMaps()
            } label: {
                Label("Open in Maps", systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.72), in: Capsule())
            }
            .padding(.trailing, 14)
            .padding(.bottom, max(12, proxy.safeAreaInsets.bottom + 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .zIndex(1)
        }
    }

    @ViewBuilder
    private func modePanel(proxy: GeometryProxy) -> some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Spacer()
                    Text("Map Modes")
                        .font(.system(size: 48/2, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()

                    Button {
                        isShowingModePanel = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                }

                HStack(spacing: 10) {
                    ForEach(MapMode.allCases) { mapMode in
                        Button {
                            mode = mapMode
                        } label: {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(mode == mapMode ? Color.blue : Color.white.opacity(0.15))
                                    .frame(height: 88)
                                    .overlay {
                                        Image(systemName: mapMode.icon)
                                            .font(.title2.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(mode == mapMode ? Color.blue : Color.white.opacity(0.3), lineWidth: 3)
                                    }

                                Text(mapMode.rawValue)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 0) {
                    panelToggleRow(title: "Traffic", isOn: $isTrafficEnabled)
                    Divider().overlay(Color.white.opacity(0.16))
                    panelToggleRow(title: "Labels", isOn: $isLabelsEnabled)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                Text("© OpenStreetMap and other data providers")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, max(16, proxy.safeAreaInsets.bottom + 10))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func panelToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.vertical, 12)
    }

    private var mapStyle: MapStyle {
        switch mode {
        case .explore:
            return .standard(elevation: .realistic)
        case .driving:
            return .hybrid(elevation: .realistic)
        case .transit:
            return .standard(elevation: .realistic)
        case .satellite:
            return .hybrid(elevation: .realistic)
        }
    }

    private func loadVenue() {
        if let initialCoordinate {
            venueCoordinate = initialCoordinate
            venueMapUnavailable = false
            venueName = initialVenueName ?? (venue.isEmpty ? city : venue)
            setMapPosition(initialCoordinate)
            return
        }

        searchForVenue()
    }

    private func searchForVenue() {
        venueMapUnavailable = false
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(venue), \(city)"

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let item = response?.mapItems.first else {
                venueCoordinate = nil
                venueMapUnavailable = true
                return
            }

            let coord = item.placemark.coordinate
            venueCoordinate = coord
            venueMapUnavailable = false
            venueName = item.name ?? venue

            setMapPosition(coord)
        }
    }

    private func setMapPosition(_ coordinate: CLLocationCoordinate2D) {
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
    }

    private func alignMapNorth() {
        guard let center = currentCenter ?? venueCoordinate else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            position = .camera(
                MapCamera(
                    centerCoordinate: center,
                    distance: max(currentDistance, 500),
                    heading: 0,
                    pitch: currentPitch
                )
            )
        }
    }

    private func togglePitch() {
        guard let center = currentCenter ?? venueCoordinate else { return }
        let nextPitch: CGFloat = currentPitch < 10 ? 55 : 0
        withAnimation(.easeInOut(duration: 0.25)) {
            position = .camera(
                MapCamera(
                    centerCoordinate: center,
                    distance: max(currentDistance, 500),
                    heading: currentHeading,
                    pitch: nextPitch
                )
            )
        }
    }

    private func recenterToVenue() {
        guard let coordinate = venueCoordinate else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            position = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
    }

    private func openInAppleMaps() {
        if let coordinate = venueCoordinate {
            let placemark = MKPlacemark(coordinate: coordinate)
            let item = MKMapItem(placemark: placemark)
            item.name = venueName.isEmpty ? venue : venueName
            item.openInMaps()
            return
        }

        let query = "\(venue), \(city)"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "http://maps.apple.com/?q=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }

}

#Preview("Bridgestone Arena – Nashville") {
    VenueMapView(city: "Nashville, TN", venue: "Bridgestone Arena")
}
