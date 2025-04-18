import SwiftUI
import MapKit
import AVKit

struct WorldView: View {
    @StateObject private var allRecordings = PerformanceViewModel()
    @State private var selectedAudioURL: URL? = nil
    @State private var audioPlayer: AVPlayer? = nil

    @State private var selectedAnnotation: RecordingAnnotation? = nil
    @State private var showDetails = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )

    var annotatedRecordings: [RecordingAnnotation] {
        allRecordings.recordings.map { recording in
            let lat = Double(recording.lat) ?? 0.0
            let lon = Double(recording.lon) ?? 0.0

            return RecordingAnnotation(
                id: recording.id,
                title: recording.title,
                date: recording.dateTimeCreated,
                recordist: recording.recordist,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                link: recording.link
            )
        }
    }


    var body: some View {
        NavigationView {
            VStack {
                Map {
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
                }
                .frame(height: 500)

                if let url = selectedAudioURL {
                    Text("🎵 Playing: \(url.lastPathComponent)")
                        .font(.caption)
                        .padding(.bottom, 5)
                }
            }
            .navigationTitle("World of 4'33")
            .onAppear {
                Task {
                    await allRecordings.fetchPerformances()
                }
            }
            .sheet(isPresented: $showDetails) {
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
            }
            .onChange(of: showDetails) {
                if !showDetails {
                    stopAudio()
                }
            }

        }
    }

    private func playAudio(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        selectedAudioURL = url
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
    }
    private func stopAudio() {
        audioPlayer?.pause()
        audioPlayer = nil
        selectedAudioURL = nil
    }

}


// 📍 Map-friendly annotation struct
struct RecordingAnnotation: Identifiable {
    let id: String
    let title: String
    let date: String
    let recordist: String
    let coordinate: CLLocationCoordinate2D
    let link: String
}

