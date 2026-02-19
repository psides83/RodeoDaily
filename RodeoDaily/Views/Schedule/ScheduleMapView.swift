//
//  ScheduleMapView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 11/10/25.
//

import SwiftUI
import MapKit

struct VenueMapView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var venueCoordinate: CLLocationCoordinate2D?
    @State private var venueName: String = ""
    
    let city: String
    let venue: String
    
    var body: some View {
        Map(position: $position) {
            if let coordinate = venueCoordinate {
                Marker(venueName, coordinate: coordinate)
                    .tint(.red)
            }
        }
        .mapStyle(.standard)
        .onAppear {
            searchForVenue()
        }
        .ignoresSafeArea()
    }
    
    private func searchForVenue() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(venue), \(city)"
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let item = response?.mapItems.first else {
                print("Search failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let coord = item.placemark.coordinate
            venueCoordinate = coord
            venueName = item.name ?? venue
            
            withAnimation {
                position = .region(
                    MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }
}

#Preview("Bridgestone Arena – Nashville") {
    // A mock version for preview only
    VenueMapPreview()
}

private struct VenueMapPreview: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.1592, longitude: -86.7785), // Bridgestone Arena
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    var body: some View {
        Map(position: $position) {
            Marker("Bridgestone Arena", coordinate: CLLocationCoordinate2D(latitude: 36.1592, longitude: -86.7785))
                .tint(.red)
        }
        .mapStyle(.hybrid)
        .ignoresSafeArea()
    }
}
