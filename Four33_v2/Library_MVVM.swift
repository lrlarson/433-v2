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


// MARK: - Main View
struct LibraryView: View {
    @State private var viewModel : LV_ViewModel     // LibraryView-ViewModel
    
    init() {
        _viewModel = State(initialValue: LV_ViewModel())
    }
    
    var body: some View {
        
        NavigationStack {
            // Headers
            HStack {
                Spacer(minLength: 16)
                Button(action: {
                    viewModel.changeSort(by: .name)
                }) {
                    HStack {
                        Text("Name")
                        if (viewModel.sortOrder == .nameAscending || viewModel.sortOrder == .nameDescending) {
                            Image(systemName: viewModel.sortOrder == .nameAscending ? "arrow.down" : "arrow.up")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button(action: {
                    viewModel.changeSort(by: .created)
                }) {
                    HStack {
                        Text("Created")
                        if (viewModel.sortOrder == .dateAscending || viewModel.sortOrder == .dateDescending) {
                            Image(systemName: viewModel.sortOrder == .dateAscending ? "arrow.down" :  "arrow.up")
                        } else {
                            Text("")
                                .frame(width: 18)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer(minLength: 16)
            }
            .padding(.horizontal)
            .padding(.bottom, 0)
            .padding(.top, 20)
            .font(.headline)
            
            List {
                ForEach(viewModel.items) { pfile in
                    FileItemRow(item: pfile, viewModel: viewModel)
                }.onDelete(perform: viewModel.fileDeleted)

            }
            .listStyle(PlainListStyle())
            .navigationTitle("Saved Performances")
            .toolbar {
                EditButton()
            }
            .padding(.bottom, 0)
            .navigationBarTitleDisplayMode(.inline)
            .font(.custom("HelveticaNeue-Light", size: 18))
        }
        .task {
            await viewModel.loadContents()
        }
        
        
        .alert("Delete recording?", isPresented: $viewModel.displayDeleteAlert) {
            Button("OK", action: viewModel.completeDelete)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete the recording \"\(viewModel.deleteURL?.lastPathComponent ?? "")\"?")
        }
    }
}

struct FileItemRow: View {
    let item: PFileItem
    let viewModel: LibraryView.LV_ViewModel
    
    var body: some View {
        HStack {
            Text(item.name)
                .font(.subheadline)
                .frame(minWidth: 190, maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 80)
            let displayableDate = item.creationDate.formatted(date: .numeric, time: .omitted)
            Text("\(displayableDate)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 100, maxWidth: .infinity)
            NavigationLink(destination: LibraryMapView(performanceURL: viewModel.parentFolderURL)){}
        }
    }
}



// MARK: - LibraryView View Model

extension LibraryView {
    
    @Observable @MainActor class LV_ViewModel {
        let parentFolderURL: URL = Files.getDocumentsDirURL()
        
        var fileItems: [PFileItem] = []
        var sortOrder: SortOrder = .dateDescending   // default sort: newest first
        var displayDeleteAlert: Bool = false
        var deleteURL : URL? = nil
        var isLoading = false
        var errorMessage: String? = nil
        var items: [PFileItem] = []

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
            self.items = sortedItems
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
            self.items = []
            
            do {
                // Get directory contents on a background thread to avoid blocking UI
                let directoryContents = try await Task.detached {
                    try FileManager.default.contentsOfDirectory(
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
                
                // Update the UI (already on MainActor)
                self.items = sortedItems
                self.isLoading = false
            } catch {
                // Handle errors (already on MainActor)
                self.errorMessage = "Error loading directory: \(error.localizedDescription)"
                self.isLoading = false
            }
        }

                
        func fileDeleted(at offsets: IndexSet) {
            for index in offsets {
                let fileName = sortedItems[index].name
                deleteURL = parentFolderURL.appendingPathComponent(fileName)
                displayDeleteAlert = true
            }
        }
        
        func completeDelete ()
        {
            displayDeleteAlert = false
            if (deleteURL != nil) {
                do {
                    try FileManager.default.removeItem(at: deleteURL!)
                    //filesFromURL(Files.getDocumentsDirURL())
                } catch {
                    print("Failed to delete file: /(error)")
                }
            }
        }
    }
}
