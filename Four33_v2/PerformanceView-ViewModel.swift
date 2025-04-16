//
//  PerformanceViewModel.swift
//  Four33_v2
//
//  Created by Larry Larson on 2/12/25.
//


import Foundation

@MainActor
class PerformanceViewModel: ObservableObject {
    @Published var recordings: [Recording] = []

    func fetchPerformances() async {
        guard let url = URL(string: "https://johncage.org/cageJSON.cfc?method=getUploadedRecordings5&returnFormat=JSON") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            // ✅ Print raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🟢 Raw JSON Response: \(jsonString)")
            }

            // ✅ Decode using APIResponse struct
            let decodedData = try JSONDecoder().decode(APIResponse.self, from: data)
            DispatchQueue.main.async {
                self.recordings = decodedData.RECORDINGS
            }

        } catch {
            print("❌ Error fetching performances: \(error)")
        }
    }
}
