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
    @State var viewModel: LV_ViewModel
    let parentFolderURL: URL
    let performanceURL: URL
    
    // State properties to store the loaded data
    @State private var mapCoordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic
    @State private var recorded: String = ""
    @State private var locationText: String = ""
    @State private var isHidden: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                if let coordinate = mapCoordinate {
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
                } else {
                    Text(locationText)
                }
                Text("")
                    .alert("Rename performance", isPresented: $viewModel.displayRenameAlert) {
                        let oldName = viewModel.perfTitle
                        TextField("New name", text:$viewModel.perfTitle)
                            .disableAutocorrection(true)
                            .onChange(of: viewModel.perfTitle) { viewModel.perfTitle = Files.trimPerfName(name: viewModel.perfTitle) }
                        Button(action: {
                            Task {
                                await viewModel.renamePerformance(oldName: oldName, newName: viewModel.perfTitle)
                            }
                        }, label: {Text("OK")})
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Enter new name for performance:")
                    }
                    .alert("Duplicate name", isPresented: $viewModel.displayDuplicateAlert) {
                        Button(action: {}, label: {Text("OK")})
                    } message: {
                        Text("A performance by that name already exists.")
                    }

                VStack {
                    Spacer()
                        .frame(height: 20)
                    Text("Recorded: \(recorded)")
                        .font(.system(size: 16))
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black))
                    Spacer()
                    HStack {
                        Button(action: {
                            Task {
                                do {
                                    try
                                    await viewModel.loadPerformance(name: viewModel.perfTitle)
                                } catch {
                                    print ("Error loading performance: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Image("play_wht-512")
                                .resizable()
                                .frame(width: 40.0, height: 48.0)
                            Text("Play")
                        }
                        .frame(width: 90 as CGFloat)

                        Spacer().frame(width: 30 as CGFloat)
                        Button("Rename", action: {
                            if (Files.isSeedRecording(name: viewModel.perfTitle)) {
                                viewModel.displaySeedRecAlert = true
                            } else {
                                viewModel.displayRenameAlert = true
                            }
                        })
                        Spacer()
                        Button("Upload"){ }
                    }
                    .frame(width: 300 as CGFloat, height: 40 as CGFloat, alignment: .center)
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 8)
                    .background(RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black))
                    Spacer().frame(height: 20)
                }
                
            }
            .navigationTitle(viewModel.perfTitle)
            .navigationBarTitleDisplayMode(.inline)
            .opacity(isHidden ? 0 : 1)
        }
        .task {
            await loadLocationData()
        }
    }
    
    private func loadLocationData() async {
        
        do {
            var latitude: Double = appConstants.NO_LOCATION_DEGREES
            var longitude: Double = appConstants.NO_LOCATION_DEGREES
            // Read geohash from metadata file
            let metadataURL = performanceURL.appending(path:Files.metadataFilename, directoryHint: .notDirectory)
            let metadata = Files.readMetaDataFromURL(url: metadataURL)
            if (metadata!.geohash == appConstants.LOCATION_NOT_RECORDED)
            {
                locationText = "Location not recorded"
            } else {
                latitude = GeoHash.area(forHash: metadata!.geohash).latitude.max as! Double
                longitude = GeoHash.area(forHash: metadata!.geohash).longitude.max as! Double
            }
            
            // Update the UI on main thread
            await MainActor.run {
                if (latitude != appConstants.NO_LOCATION_DEGREES) {
                    self.mapCoordinate = CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    )
                }
                
                if (metadata != nil) {
                    viewModel.perfTitle = metadata!.title
                    let dateStr = metadata!.created
                    recorded = Files.strToDateAndTime(dateStr: dateStr)?.formatted( date: .long, time: .shortened) ?? ""
                }
            }
        }
        isHidden = false;
    }
    
}
        
        
