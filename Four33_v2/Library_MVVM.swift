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


// MARK: - LibraryView View Model (also passed to LibraryMapView)
@Observable @MainActor class LV_ViewModel {
    let parentFolderURL: URL = Files.getDocumentsDirURL()
    
    var fileItems: [PFileItem] = []
    var sortColumn: SortColumn = .created
    var sortOrder: SortOrder = .dateDescending   // default sort: newest first
    var displayDeleteAlert: Bool = false
    var displaySeedRecordingAlert: Bool = false
    var deleteURL : URL? = nil
    var isLoading = false
    var errorMessage: String? = nil
    var deleteFileName: String? = nil
    var displayRenameAlert: Bool = false
    var displaySeedRecAlert: Bool = false
 
    
    enum SortOrder {
        case nameAscending, nameDescending, dateAscending, dateDescending
    }
    
    var sortedItems: [PFileItem] {
        let sorted = fileItems.sorted {
            switch sortOrder {
            case .nameAscending:
                return $0.name > $1.name
            case .nameDescending:
                return $0.name < $1.name
            case .dateAscending:
                return $0.creationDate > $1.creationDate
            case .dateDescending:
                return $0.creationDate < $1.creationDate
            }
        }
        return sorted
    }
    
    func changeSort() {
        switch sortColumn {
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
            changeSort()
            self.isLoading = false
        } catch {
            // Handle errors (already on MainActor)
            self.errorMessage = "Error loading directory: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    
    func loadPerformance(name: String) async throws {
        await loadContents()    // Temp function; replace this
    }
    
    
    func renamePerformance(oldName: String, newName: String) async {
        // TODO: check for Seed recording; don't allow rename if yes.
        
        //  Update the performance name in the metadata
        let metadataURL = parentFolderURL.appending(path:oldName, directoryHint: .isDirectory)
                                         .appending(path:Files.metadataFilename, directoryHint: .notDirectory)
        var metadata = Files.readMetaDataFromURL(url: metadataURL)
        metadata!.title = newName
        do {
            try Files.writeMetadataToURL(url: metadataURL, metadata: metadata!)
        } catch {
            // TODO: need better error handling;
            //  post alert about duplicate name
            print("Error saving metadata for rename: \(error)")
        }
 
        // Rename the folder containing the performance
        let srcURL = parentFolderURL.appendingPathComponent(oldName)
        let dstURL = parentFolderURL.appendingPathComponent(newName)
        do {
            try FileManager.default.moveItem(at: srcURL, to: dstURL) }
        catch {
            print("Error renaming performance \(oldName) to \(newName): \(error)")
            return
        }
        
        // Refresh file list in parent view
        await loadContents()
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
