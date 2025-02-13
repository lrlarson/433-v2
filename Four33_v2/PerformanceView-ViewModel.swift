//
//  PerformanceViewModel.swift
//  Four33_v2
//
//  Created by Larry Larson on 2/12/25.
//
import Foundation

@MainActor

class PerformanceViewModel: ObservableObject{
    @Published var performances: [Performance] = []
        func fetchPerformances() async {
          guard let url = URL(string: "https:johncage.org?method=getUploadedRecordings2&returnFormat=JSON") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                        let (data, _) = try await URLSession.shared.data(for: request)
                        performances = try JSONDecoder().decode([Performance].self, from: data)
                   } catch {
                        print("Error fetching performances: \(error)")
                   }
    }
}

