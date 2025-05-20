//
//  LibraryMap_MVVM.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/11/25.
//

import SwiftUI
import MapKit

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let title: String?
}

struct LibraryMapView: View {
    var performanceURL: URL
        
    // State properties to store the loaded data
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic
    @State private var perfTitle: String = ""
    @State private var recorded: String = ""
    
    var body: some View {
        
        NavigationView {
            ZStack {
                if let coordinate = coordinate {
                    Map(position: $position) {
                        // Add a marker at the specified coordinate
                        Marker("", coordinate: coordinate)
                            .tint(.purple)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        // Set camera position once coordinates are loaded
                        position = .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
                        ))
                    }
                }
                else {
                    Text("No location data recorded.")
                }
                
                VStack {
                    Spacer()
                        .frame(height: 20)
                    Text("Recorded: \(recorded)")
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black))
                    Spacer()
                }
                
            }
            .navigationTitle(perfTitle)
            .navigationBarTitleDisplayMode(.inline)

        }
        .task {
            await loadLocationData()
        }
    }
    
    private func loadLocationData() async {
        
        do {
            // Read geohash from metadata file
            let metadata = Files.readMetaDataFromURL(url: performanceURL.appendingPathComponent(Files.metadataFilename))
            if (metadata!.geohash == appConstants.LOCATION_NOT_RECORDED)
            {
                return
            }
            let latitude = GeoHash.area(forHash: metadata!.geohash).latitude.max as! Double
            let longitude = GeoHash.area(forHash: metadata!.geohash).longitude.max as! Double

            // Update the UI on main thread
            await MainActor.run {
                self.coordinate = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                )
                
                if (metadata != nil) {
                    self.perfTitle = metadata!.title
                    let calendar = Calendar.current
                    let dateCompacted = metadata!.created
                    var components = DateComponents()
                    components.year = Int(dateCompacted.prefix(4))
                    components.month = Int(dateCompacted.dropFirst(4).prefix(2))
                    components.day = Int(dateCompacted.dropFirst(6).prefix(2))
                    components.hour = Int(dateCompacted.dropFirst(8).prefix(2))
                    components.minute = Int(dateCompacted.dropFirst(10).prefix(2))
                    components.second = Int(dateCompacted.dropFirst(12).prefix(2))
                    if let pdate = calendar.date(from: components) {
                        recorded = pdate.formatted( date: .long, time: .shortened)
                    }
                }
            }
        }
    }
}
        
        
