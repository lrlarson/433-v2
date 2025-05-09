//
//  About433View.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/11/25.
//

import SwiftUI
import MapKit


struct LibraryMapView: View {
    let performanceURL: URL
    
    @State var viewModel = LMV_ViewModel()      // LibraryMapView-ViewModel

    var body: some View {
        NavigationView {
            VStack {
                Map {
                    /*
                    Annotation("", coordinate: viewModel.mapLocation.coordinate) {
                        VStack {
                            Image(systemName: "mappin")
                                .foregroundColor(.purple)
                                /*
                                .onTapGesture {
                                    selectedAnnotation = item
                                    showDetails = true
                                    playAudio(urlString: item.link)
                                }
                                 */
                                .font(.system(size: 30))
                        }
                    }
                    */

                    /*
                    ForEach(annotatedRecordings) { item in
                        Annotation("", coordinate: item.coordinate) {
                            VStack {
                                Image(systemName: "mappin")
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        selectedAnnotation = item
                                        showDetails = true
                                        playAudio(urlString: item.link)
                                    }
                                    .font(.system(size: 30))
                            }
                        }
                    }
                    */
                }
                
                /*
                if let url = selectedAudioURL {
                    Text("🎵 Playing: \(url.lastPathComponent)")
                        .font(.caption)
                        .padding(.bottom, 5)
                }
                */
                //View() {
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .font(.custom("HelveticaNeue-Light", size: 18))
            .navigationTitle("World of 4'33")           // TODO: performance title goes here
            .onAppear {
                //viewModel.makeMapLocation(perfURL:performanceURL)
            }
            //.sheet(isPresented: $showDetails) {
                /*
                if let item = selectedAnnotation {
                    VStack(spacing: 10) {
                        Text("📅 Date: \(item.date)")
                        Text("🎵 Title: \(item.title)")
                        Text("🎙️ Recordist: \(item.recordist)")
                        Button("Close") {
                            showDetails = false
                        }
                        .padding(.top)
                    }
                    .padding()
                    .presentationDetents([.fraction(0.25)]) // Optional for iOS 16+
                }
                 */
            }
        }

// MARK: - LibraryMapView View Model

extension LibraryMapView {
    
    @Observable @MainActor class LMV_ViewModel {}
}
