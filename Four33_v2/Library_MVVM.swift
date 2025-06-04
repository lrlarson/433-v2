//
//  Library_MVVM.swift
//  Four33_v2
//
//  Created by PKSTONE on 04/25/25.
//

import Foundation
import SwiftUI
import MapKit
import Observation

// MARK: - Model
struct PFileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let creationDate: Date
    
    
    static func fileFromURL(_ p_url: URL) throws -> PFileItem? {
        let resourceValues = try p_url.resourceValues(forKeys: [
            .creationDateKey
        ])
        
        return PFileItem(
            name: p_url.lastPathComponent,
            creationDate: resourceValues.creationDate ?? Date()
        )
    }
}


// MARK: - LibraryView View Model
@Observable @MainActor class LV_ViewModel {
    let parentFolderURL: URL = Files.getDocumentsDirURL()
    
    var fileItems: [PFileItem] = []
    var sortOrder: SortOrder = .dateDescending   // default sort: newest first
    var displayDeleteAlert: Bool = false
    var displaySeedRecordingAlert: Bool = false
    var deleteURL : URL? = nil
    var isLoading = false
    var errorMessage: String? = nil
    var deleteFileName: String? = nil
    var refreshToggle: Bool = false
    
    
    
    enum SortOrder {
        case nameAscending, nameDescending, dateAscending, dateDescending
    }
    
    var sortedItems: [PFileItem] {
        let sorted = fileItems.sorted {
            switch sortOrder {
            case .nameAscending:
                return $0.name < $1.name
            case .nameDescending:
                return $0.name > $1.name
            case .dateAscending:
                return $0.creationDate < $1.creationDate
            case .dateDescending:
                return $0.creationDate > $1.creationDate
            }
        }
        return sorted
    }
    
    func changeSort(by column: SortColumn) {
        switch column {
        case .name:
            sortOrder = (sortOrder == .nameAscending) ? .nameDescending : .nameAscending
        case .created:
            sortOrder = (sortOrder == .dateAscending) ? .dateDescending : .dateAscending
        }
        self.fileItems = sortedItems
    }
    
    enum SortColumn {
        case name, created
    }
    
    private var metadata = RecordingMetaData()
    var pieceName = ""
    
    
    // Load the contents of the current directory
    func loadContents() async {
        isLoading = true
        errorMessage = nil
        fileItems = []
        let fileManager = FileManager.default
        
        do {
            // Get directory contents on a background thread to avoid blocking UI
            let directoryContents = try await Task.detached {
                try fileManager.contentsOfDirectory(
                    at: self.parentFolderURL,
                    includingPropertiesForKeys: [
                        .creationDateKey
                    ]
                )
            }.value
            
            // Process each file to create FileItem objects
            for url in directoryContents {
                do {
                    let item = (try PFileItem.fileFromURL(url))!
                    fileItems.append(item)
                } catch {
                    print("Error processing file \(url.lastPathComponent): \(error)")
                }
            }
            
            // Add the permanent recording to the list
            let seed_recording_date = Files.strToDate(dateStr: appConstants.SEED_RECORDING_DATE)
            let item = PFileItem(name: appConstants.SEED_RECORDING_DISPLAY_NAME, creationDate: seed_recording_date!)
            fileItems.append(item)
            
            // Update the UI (already on MainActor)
            self.isLoading = false
        } catch {
            // Handle errors (already on MainActor)
            self.errorMessage = "Error loading directory: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    
    func completeDelete(at offsets: IndexSet)
    {
        displayDeleteAlert = false
        let filesToDelete = offsets.map { fileItems[$0] }
        var indicesToRemove = IndexSet()
        let fileManager = FileManager.default
        // Try to delete each file
        for (index, fileURL) in zip(offsets, filesToDelete) {
            deleteURL = parentFolderURL.appendingPathComponent(fileURL.name)
            if (deleteURL != nil)
            {
                do {
                    try fileManager.removeItem(at: deleteURL!)
                    indicesToRemove.insert(index)
                } catch {
                    print("Failed to delete file: /(fileURL.lastPathComponent): \(error.localizedDescription)")
                    break
                }
            }
        }
        
        fileItems.remove(atOffsets: indicesToRemove)
    }
}
