//
//  ScheduleSeasonMapView.swift
//  RodeoDaily
//
//  Created by Codex on 5/20/26.
//

import SwiftUI
import MapKit
import UIKit

struct ScheduleSeasonMapView: View {
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

    private let initialRodeos: [RodeoData]
    private let apiUrls = ApiUrls()

    @Environment(\.dismiss) private var dismiss
    @State private var rodeos: [RodeoData]
    @State private var selectedRodeoID: Int?
    @State private var selectedState = "All"
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var hasLoadedFullSeason = false
    @State private var loadedDateWindow: SeasonMapDateWindow?
    @State private var isShowingFilters = false
    @State private var isLoadingSeason = false
    @State private var loadingMessage = "Loading rodeos..."
    @State private var seasonLoadFailed = false
    @State private var mode: MapMode = .satellite
    @State private var isShowingModePanel = false
    @State private var currentHeading: CLLocationDirection = 0
    @State private var currentPitch: CGFloat = 0
    @State private var currentDistance: CLLocationDistance = 9000
    @State private var currentCenter: CLLocationCoordinate2D?
    @State private var mapAction: SeasonMapAction?

    private let controlSize: CGFloat = 56
    private let controlSpacing: CGFloat = 12
    private let mapsButtonHeight: CGFloat = 40

    init(rodeos: [RodeoData]) {
        initialRodeos = rodeos
        _rodeos = State(initialValue: rodeos)

        let today = Calendar.current.startOfDay(for: Date())
        let twoWeeksOut = Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
        _startDate = State(initialValue: today)
        _endDate = State(initialValue: twoWeeksOut)
    }

    private var states: [String] {
        let values = Set(rodeos.map(\.state).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        return ["All"] + values.sorted()
    }

    private var filteredRodeos: [RodeoData] {
        rodeos
            .filter { $0.coordinate != nil }
            .filter { rodeo in
                selectedState == "All" || rodeo.state == selectedState
            }
            .filter { rodeo in
                guard startDate != nil || endDate != nil else { return true }
                return rodeo.overlapsDateRange(startDate: startDate, endDate: endDate)
            }
            .sorted { lhs, rhs in
                let lhsDate = lhs.startDate.rodeoDate ?? lhs.endDate.rodeoDate ?? .distantFuture
                let rhsDate = rhs.startDate.rodeoDate ?? rhs.endDate.rodeoDate ?? .distantFuture
                return lhsDate < rhsDate
            }
    }

    private var selectedRodeo: RodeoData? {
        guard let selectedRodeoID else { return nil }
        return filteredRodeos.first { $0.id == selectedRodeoID }
    }

    private var isIn3D: Bool {
        currentPitch >= 10
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScheduleClusteredMapView(
                    rodeos: filteredRodeos,
                    selectedRodeoID: $selectedRodeoID,
                    mode: mode,
                    action: mapAction
                ) { heading, pitch, distance, center in
                    currentHeading = heading
                    currentPitch = pitch
                    currentDistance = distance
                    currentCenter = center
                }
                .ignoresSafeArea()

                if !isShowingModePanel {
                    topControls
                }

                rightControls(proxy: proxy)
                openInMapsButton(proxy: proxy)

                if isShowingModePanel {
                    modePanel(proxy: proxy)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if isLoadingSeason {
                    loadingOverlay
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isShowingModePanel)
            .ignoresSafeArea()
        }
        .navigationTitle("Season Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomSummary
        }
        .sheet(isPresented: $isShowingFilters) {
            filterSheet
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
        }
        .onAppear(perform: fitVisibleRodeos)
        .task {
            await loadDateWindowRodeosIfNeeded()
        }
        .onChange(of: selectedState) { _, _ in
            selectedRodeoID = nil
            fitVisibleRodeos()
        }
        .onChange(of: startDate) { _, _ in
            selectedRodeoID = nil
            fitVisibleRodeos()
            Task {
                await loadDateWindowRodeosIfNeeded()
            }
        }
        .onChange(of: endDate) { _, _ in
            selectedRodeoID = nil
            fitVisibleRodeos()
            Task {
                await loadDateWindowRodeosIfNeeded()
            }
        }
    }

    private var topControls: some View {
        HStack(spacing: AppSpace.sm) {
            Button {
                isShowingFilters = true
            } label: {
                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, AppSpace.md)
                    .padding(.vertical, AppSpace.sm)
                    .background(.ultraThinMaterial, in: Capsule())
            }

            Spacer()

            Button {
                fitVisibleRodeos()
            } label: {
                Image(systemName: "mappin.and.ellipse")
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, AppSpace.md)
                    .padding(.vertical, AppSpace.sm)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(.horizontal, AppSpace.md)
        .padding(.top, AppSpace.sm)
    }

    @ViewBuilder
    private func rightControls(proxy: GeometryProxy) -> some View {
        if !isShowingModePanel {
            let stackHeight = (controlSize * 4) + (controlSpacing * 2)
            let bottomInset = proxy.safeAreaInsets.bottom + mapsButtonHeight + 86
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
                            .frame(width: controlSize, height: controlSize)
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
                            .frame(width: controlSize, height: controlSize)
                            .contentTransition(.numericText())
                    }

                    Divider()
                        .overlay(Color.white.opacity(0.2))
                        .frame(width: controlSize - 20)

                    Button {
                        recenterMap()
                    } label: {
                        Image(systemName: "location.north.line.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: controlSize, height: controlSize)
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
                        .frame(width: controlSize, height: controlSize)
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
        if !isShowingModePanel, selectedRodeo?.coordinate != nil {
            Button {
                openSelectedInAppleMaps()
            } label: {
                Label("Open in Maps", systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.72), in: Capsule())
            }
            .padding(.trailing, 14)
            .padding(.bottom, max(76, proxy.safeAreaInsets.bottom + 72))
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
                        .font(.system(size: 24, weight: .bold, design: .rounded))
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

    private var bottomSummary: some View {
        HStack(spacing: AppSpace.sm) {
            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                Text(summaryTitle)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                Text(filterSummary)
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
                    .lineLimit(1)
            }

            Spacer()

            if !hasLoadedFullSeason {
                Button("Load Season") {
                    Task {
                        await loadWholeSeason()
                    }
                }
                .disabled(isLoadingSeason)
                .font(.appCaptionStrong)
                .foregroundColor(.appSecondary)
            } else if hasActiveFilters {
                Button("Reset") {
                    resetDefaultFilters()
                }
                .font(.appCaptionStrong)
                .foregroundColor(.appSecondary)
            }
        }
        .padding(AppSpace.md)
        .background(.ultraThinMaterial)
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("State") {
                    Picker("State", selection: $selectedState) {
                        ForEach(states, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                }

                Section("Dates") {
                    if hasLoadedFullSeason && startDate == nil && endDate == nil {
                        Label("Whole season loaded", systemImage: "calendar")
                            .foregroundColor(.appSecondary)
                    } else {
                        SwiftUI.DatePicker("Starts After", selection: startDateBinding, displayedComponents: .date)
                        SwiftUI.DatePicker("Ends Before", selection: endDateBinding, displayedComponents: .date)
                    }
                }

                Section {
                    Button("Use Next 2 Weeks") {
                        resetDefaultFilters()
                    }

                    Button("Load Whole Season") {
                        Task {
                            isShowingFilters = false
                            await loadWholeSeason()
                        }
                    }
                    .disabled(isLoadingSeason || hasLoadedFullSeason && startDate == nil && endDate == nil)
                }
            }
            .navigationTitle("Map Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isShowingFilters = false
                    }
                }
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: AppSpace.sm) {
                ProgressView()
                    .tint(.appPrimary)
                Text(loadingMessage)
                    .font(.appBodyStrong)
                    .foregroundColor(.appPrimary)
                Text("Preparing the map pins")
                    .font(.appCaption)
                    .foregroundColor(.appTertiary)
            }
            .padding(AppSpace.lg)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.horizontal, AppSpace.xl)
        }
        .zIndex(10)
        .allowsHitTesting(true)
    }

    private var summaryTitle: String {
        if isLoadingSeason {
            return loadingMessage
        }
        if seasonLoadFailed {
            return "\(filteredRodeos.count) loaded rodeos mapped"
        }
        return "\(filteredRodeos.count) rodeos mapped"
    }

    private var filterSummary: String {
        var parts = [String]()

        if selectedState != "All" {
            parts.append(selectedState)
        }
        if let startDate, let endDate {
            parts.append("\(startDate.formatted(date: .abbreviated, time: .omitted)) - \(endDate.formatted(date: .abbreviated, time: .omitted))")
        } else if let startDate {
            parts.append("after \(startDate.formatted(date: .abbreviated, time: .omitted))")
        } else if let endDate {
            parts.append("before \(endDate.formatted(date: .abbreviated, time: .omitted))")
        }

        return parts.isEmpty ? "All states and dates" : parts.joined(separator: " · ")
    }

    private var hasActiveFilters: Bool {
        selectedState != "All" || startDate != nil || endDate != nil
    }

    private var startDateBinding: Binding<Date> {
        Binding(
            get: { startDate ?? Calendar.current.startOfDay(for: Date()) },
            set: { startDate = Calendar.current.startOfDay(for: $0) }
        )
    }

    private var endDateBinding: Binding<Date> {
        Binding(
            get: {
                if let endDate { return endDate }
                let today = Calendar.current.startOfDay(for: Date())
                return Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
            },
            set: { endDate = Calendar.current.startOfDay(for: $0) }
        )
    }

    private func resetDefaultFilters() {
        let today = Calendar.current.startOfDay(for: Date())
        selectedState = "All"
        startDate = today
        endDate = Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
        hasLoadedFullSeason = false
        Task {
            await loadDateWindowRodeosIfNeeded()
        }
    }

    private func clearDateFiltersForLoadedSeason() {
        selectedState = "All"
        startDate = nil
        endDate = nil
    }

    private func loadDateWindowRodeosIfNeeded() async {
        guard !hasLoadedFullSeason, startDate != nil || endDate != nil else { return }
        let dateWindow = SeasonMapDateWindow(startDate: startDate, endDate: endDate)
        guard loadedDateWindow != dateWindow else { return }
        await loadCloudflareRodeos(startDate: startDate, endDate: endDate, loadingMessage: "Loading nearby rodeos...")
        if !seasonLoadFailed {
            loadedDateWindow = dateWindow
        }
    }

    private func loadWholeSeason() async {
        guard !hasLoadedFullSeason else { return }
        await loadCloudflareRodeos(startDate: nil, endDate: nil, loadingMessage: "Loading full season...")
        hasLoadedFullSeason = !seasonLoadFailed
        if hasLoadedFullSeason {
            loadedDateWindow = nil
            clearDateFiltersForLoadedSeason()
        }
    }

    private func loadCloudflareRodeos(startDate: Date?, endDate: Date?, loadingMessage: String) async {
        guard !isLoadingSeason else { return }

        isLoadingSeason = true
        self.loadingMessage = loadingMessage
        seasonLoadFailed = false
        defer { isLoadingSeason = false }

        do {
            let pageLimit = 200
            let maxPages = 10
            var loaded = [RodeoData]()

            for page in 0..<maxPages {
                let url = apiUrls.cloudflareSeasonRodeosUrl(
                    seasonYear: 2026,
                    limit: pageLimit,
                    offset: page * pageLimit,
                    startDate: startDate,
                    endDate: endDate
                )
                let pageData = try await APIClient.fetch(RodeoSchedule.self, from: url).data

                guard !pageData.isEmpty else {
                    break
                }

                loaded.append(contentsOf: pageData)

                if pageData.count < pageLimit {
                    break
                }
            }

            let merged = PaginatedRodeoLoader.uniqueById(initialRodeos + loaded)
            if !merged.isEmpty {
                rodeos = merged
                fitVisibleRodeos()
            }
        } catch {
            seasonLoadFailed = true
            rodeos = initialRodeos
        }
    }

    private func fitVisibleRodeos() {
        mapAction = SeasonMapAction(kind: .fitVisible)
    }

    private func recenterMap() {
        mapAction = SeasonMapAction(kind: selectedRodeo == nil ? .fitVisible : .recenterSelected)
    }

    private func alignMapNorth() {
        guard currentCenter != nil || selectedRodeo?.coordinate != nil else { return }
        mapAction = SeasonMapAction(kind: .alignNorth)
    }

    private func togglePitch() {
        guard currentCenter != nil || selectedRodeo?.coordinate != nil else { return }
        mapAction = SeasonMapAction(kind: .togglePitch)
    }

    private func openSelectedInAppleMaps() {
        guard let selectedRodeo, let coordinate = selectedRodeo.coordinate else { return }

        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = selectedRodeo.venueName.isEmpty ? selectedRodeo.name : selectedRodeo.venueName
        item.openInMaps()
    }
}

struct SeasonMapAction: Equatable {
    enum Kind {
        case fitVisible
        case recenterSelected
        case alignNorth
        case togglePitch
    }

    let id = UUID()
    let kind: Kind
}

private struct SeasonMapDateWindow: Equatable {
    let startDate: Date?
    let endDate: Date?
}

struct ScheduleClusteredMapView: UIViewRepresentable {
    let rodeos: [RodeoData]
    @Binding var selectedRodeoID: Int?
    let mode: ScheduleSeasonMapView.MapMode
    let action: SeasonMapAction?
    let onCameraChange: (CLLocationDirection, CGFloat, CLLocationDistance, CLLocationCoordinate2D?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsUserLocation = false
        mapView.pointOfInterestFilter = .excludingAll

        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = context.coordinator
        mapView.addGestureRecognizer(tapRecognizer)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        mapView.mapType = mode.mapType
        context.coordinator.syncAnnotations(on: mapView, rodeos: rodeos)
        context.coordinator.syncSelection(on: mapView, selectedRodeoID: selectedRodeoID)
        context.coordinator.perform(action, on: mapView, selectedRodeoID: selectedRodeoID)
    }

    final class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: ScheduleClusteredMapView
        private var annotationIDs = Set<Int>()
        private var lastActionID: UUID?
        private var hasFitInitialRegion = false

        init(_ parent: ScheduleClusteredMapView) {
            self.parent = parent
        }

        func syncAnnotations(on mapView: MKMapView, rodeos: [RodeoData]) {
            let nextIDs = Set(rodeos.map(\.id))
            guard nextIDs != annotationIDs else {
                if !hasFitInitialRegion {
                    fitVisibleAnnotations(on: mapView, animated: false)
                    hasFitInitialRegion = true
                }
                return
            }

            let currentAnnotations = mapView.annotations.compactMap { $0 as? RodeoMapAnnotation }
            let currentByID = Dictionary(uniqueKeysWithValues: currentAnnotations.map { ($0.rodeo.id, $0) })
            let removeIDs = annotationIDs.subtracting(nextIDs)
            let addRodeos = rodeos.filter { !annotationIDs.contains($0.id) }

            let annotationsToRemove = removeIDs.compactMap { currentByID[$0] }
            mapView.removeAnnotations(annotationsToRemove)

            let annotationsToAdd = addRodeos.compactMap(RodeoMapAnnotation.init)
            mapView.addAnnotations(annotationsToAdd)

            annotationIDs = nextIDs
            fitVisibleAnnotations(on: mapView, animated: false)
            hasFitInitialRegion = true
        }

        func syncSelection(on mapView: MKMapView, selectedRodeoID: Int?) {
            guard let selectedRodeoID else { return }
            guard let annotation = mapView.annotations.compactMap({ $0 as? RodeoMapAnnotation }).first(where: { $0.rodeo.id == selectedRodeoID }) else {
                return
            }
            if !mapView.selectedAnnotations.contains(where: { ($0 as? RodeoMapAnnotation)?.rodeo.id == selectedRodeoID }) {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }

        func perform(_ action: SeasonMapAction?, on mapView: MKMapView, selectedRodeoID: Int?) {
            guard let action, action.id != lastActionID else { return }
            lastActionID = action.id

            switch action.kind {
            case .fitVisible:
                fitVisibleAnnotations(on: mapView, animated: true)
            case .recenterSelected:
                recenterSelected(on: mapView, selectedRodeoID: selectedRodeoID)
            case .alignNorth:
                alignNorth(on: mapView)
            case .togglePitch:
                togglePitch(on: mapView)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: "cluster")
                view.annotation = cluster
                view.markerTintColor = .systemBlue
                view.glyphText = "\(cluster.memberAnnotations.count)"
                view.canShowCallout = false
                return view
            }

            guard let rodeoAnnotation = annotation as? RodeoMapAnnotation else {
                return nil
            }

            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "rodeo") as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: rodeoAnnotation, reuseIdentifier: "rodeo")
            view.annotation = rodeoAnnotation
            view.clusteringIdentifier = "rodeo"
            view.markerTintColor = .systemRed
            view.glyphImage = UIImage(systemName: "mappin")
            view.canShowCallout = true
            view.titleVisibility = .adaptive
            view.subtitleVisibility = .adaptive
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if let cluster = annotation as? MKClusterAnnotation {
                mapView.deselectAnnotation(cluster, animated: false)
                mapView.showAnnotations(cluster.memberAnnotations, animated: true)
                return
            }

            guard let rodeoAnnotation = annotation as? RodeoMapAnnotation else { return }
            parent.selectedRodeoID = rodeoAnnotation.rodeo.id
        }

        func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
            guard let rodeoAnnotation = annotation as? RodeoMapAnnotation,
                  parent.selectedRodeoID == rodeoAnnotation.rodeo.id else {
                return
            }
            parent.selectedRodeoID = nil
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.onCameraChange(
                mapView.camera.heading,
                mapView.camera.pitch,
                mapView.camera.altitude,
                mapView.centerCoordinate
            )
        }

        @objc func handleMapTap(_ recognizer: UITapGestureRecognizer) {
            guard let mapView = recognizer.view as? MKMapView else { return }
            let point = recognizer.location(in: mapView)
            if mapView.hitTest(point, with: nil) is MKAnnotationView {
                return
            }
            for annotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(annotation, animated: true)
            }
            parent.selectedRodeoID = nil
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        private func fitVisibleAnnotations(on mapView: MKMapView, animated: Bool) {
            let annotations = mapView.annotations.compactMap { $0 as? RodeoMapAnnotation }
            guard !annotations.isEmpty else { return }

            if annotations.count == 1, let coordinate = annotations.first?.coordinate {
                mapView.setRegion(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
                    ),
                    animated: animated
                )
                return
            }

            mapView.showAnnotations(annotations, animated: animated)
        }

        private func recenterSelected(on mapView: MKMapView, selectedRodeoID: Int?) {
            guard let selectedRodeoID,
                  let annotation = mapView.annotations.compactMap({ $0 as? RodeoMapAnnotation }).first(where: { $0.rodeo.id == selectedRodeoID }) else {
                fitVisibleAnnotations(on: mapView, animated: true)
                return
            }

            mapView.setRegion(
                MKCoordinateRegion(
                    center: annotation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
                ),
                animated: true
            )
        }

        private func alignNorth(on mapView: MKMapView) {
            let camera = mapView.camera.copy() as? MKMapCamera ?? mapView.camera
            camera.heading = 0
            mapView.setCamera(camera, animated: true)
        }

        private func togglePitch(on mapView: MKMapView) {
            let camera = mapView.camera.copy() as? MKMapCamera ?? mapView.camera
            camera.pitch = camera.pitch < 10 ? 55 : 0
            mapView.setCamera(camera, animated: true)
        }
    }
}

private final class RodeoMapAnnotation: NSObject, MKAnnotation {
    let rodeo: RodeoData
    let coordinate: CLLocationCoordinate2D

    var title: String? {
        rodeo.name
    }

    var subtitle: String? {
        "\(rodeo.location) • \(dateDisplay)"
    }

    init?(_ rodeo: RodeoData) {
        guard let coordinate = rodeo.coordinate else { return nil }
        self.rodeo = rodeo
        self.coordinate = coordinate
    }

    private var dateDisplay: String {
        let start = rodeo.startDate.rodeoDate?.formatted(date: .abbreviated, time: .omitted) ?? "TBD"
        let end = rodeo.endDate.rodeoDate?.formatted(date: .abbreviated, time: .omitted) ?? "TBD"

        if start == end {
            return start
        }
        return "\(start) - \(end)"
    }
}

private extension ScheduleSeasonMapView.MapMode {
    var mapType: MKMapType {
        switch self {
        case .explore:
            return .standard
        case .driving:
            return .hybrid
        case .transit:
            return .mutedStandard
        case .satellite:
            return .satellite
        }
    }
}

private struct OptionalDateRow: View {
    let title: String
    @Binding var date: Date?

    private var dateBinding: Binding<Date> {
        Binding(
            get: { date ?? Date() },
            set: { date = $0 }
        )
    }

    var body: some View {
        HStack {
            if date == nil {
                Button {
                    date = Date()
                } label: {
                    Label(title, systemImage: "calendar.badge.plus")
                }
            } else {
                SwiftUI.DatePicker(title, selection: dateBinding, displayedComponents: .date)
                Button {
                    date = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private extension RodeoData {
    var mapDateDisplay: String {
        let start = startDate.rodeoDate?.formatted(date: .abbreviated, time: .omitted) ?? "TBD"
        let end = endDate.rodeoDate?.formatted(date: .abbreviated, time: .omitted) ?? "TBD"

        if start == end {
            return start
        }
        return "\(start) - \(end)"
    }

    func overlapsDateRange(startDate filterStart: Date?, endDate filterEnd: Date?) -> Bool {
        let rodeoStart = startDate.rodeoDate ?? endDate.rodeoDate
        let rodeoEnd = endDate.rodeoDate ?? startDate.rodeoDate

        guard let rodeoStart, let rodeoEnd else {
            return filterStart == nil && filterEnd == nil
        }

        if let filterStart, rodeoEnd < Calendar.current.startOfDay(for: filterStart) {
            return false
        }

        if let filterEnd {
            let endOfFilterDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: filterEnd)) ?? filterEnd
            if rodeoStart >= endOfFilterDay {
                return false
            }
        }

        return true
    }
}
