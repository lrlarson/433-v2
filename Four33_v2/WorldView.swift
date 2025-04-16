//worldview

//
//  WorldView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//
import SwiftUI
import AVKit

struct WorldView: View {
    @StateObject private var allRecordings = PerformanceViewModel()
    @State private var selectedAudioURL: URL? = nil
    @State private var audioPlayer: AVPlayer? = nil

    var body: some View {
        NavigationView {
            VStack {
                List(allRecordings.recordings) { recording in
                    VStack(alignment: .leading) {
                        Text(recording.title)
                            .font(.headline)
                        Text("Recorded by: \(recording.recordist)")
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        if let url = URL(string: recording.link) {
                            selectedAudioURL = url
                            audioPlayer = AVPlayer(url: url)
                            audioPlayer?.play()
                        } else {
                            print("Invalid audio URL for recording: \(recording.title)")
                        }
                    }
                }
                .navigationTitle("World of 4'33")

                // Optional: Show what’s playing
                if let url = selectedAudioURL {
                    Text("🎵 Playing: \(url.lastPathComponent)")
                        .font(.caption)
                        .padding()
                }
            }
            .onAppear {
                Task {
                    await allRecordings.fetchPerformances()
                }
            }
        }
    }
}






#Preview {
    WorldView()
}
