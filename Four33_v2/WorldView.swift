import SwiftUI
import MapKit
import AVKit

struct WorldView: View {
    @StateObject private var allRecordings = PerformanceViewModel()
    @State private var selectedAudioURL: URL? = nil
    @State private var audioPlayer: AVPlayer? = nil

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )

    // Convert your recordings into annotation-ready structs
    var annotatedRecordings: [RecordingAnnotation] {
        allRecordings.recordings.compactMap { recording in
            guard let lat = Double(recording.lat),
                  let lon = Double(recording.lon) else {
                return nil
            }
            return RecordingAnnotation(
                id: recording.id,
                title: recording.title,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                link: recording.link
            )
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                
                    // ✅ iOS 17+ Map using Annotation(content:)
                    Map() {
                        ForEach(annotatedRecordings) { item in
                            Annotation("", coordinate: item.coordinate) {
                                VStack {
                                    Image(systemName: "mappin")
                                        .foregroundColor(.green)
                                        .onTapGesture {
                                            playAudio(urlString: item.link)
                                        }
                                        .font(.system(size: 30))  
                                   
                                }
                            }
                        }
                    }
                    .frame(height: 500)
                 
                   
                   
                

                // Optional playback feedback
                if let url = selectedAudioURL {
                    Text("🎵 Playing: \(url.lastPathComponent)")
                        .font(.caption)
                        .padding(.bottom, 5)
                }

                // Optional: list below the map
                /*
                List(allRecordings.recordings) { recording in
                    VStack(alignment: .leading) {
                        Text(recording.title)
                            .font(.headline)
                        Text("Recorded by: \(recording.recordist)")
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        playAudio(urlString: recording.link)
                    }
                }
                 */
            }
            .navigationTitle("World of 4'33")
            .onAppear {
                Task {
                    await allRecordings.fetchPerformances()
                }
            }
        }
    }

    // 🔊 Reusable audio playback logic
    private func playAudio(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        selectedAudioURL = url
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
    }
}

// 📍 Map-friendly annotation struct
struct RecordingAnnotation: Identifiable {
    let id: String
    let title: String
    let coordinate: CLLocationCoordinate2D
    let link: String
}
