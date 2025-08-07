//
//  LibraryView.swift
//  Four33_v2
//
//  Created by PKSTONE on 6/2/25.
//

import Foundation
import SwiftUI

struct LibraryView: View {
    @State var viewModel = LV_ViewModel()     // LibraryView-ViewModel
    @State private var itemsToDelete: IndexSet?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        NavigationStack {
            // Headers
            HStack {
                Spacer(minLength: 16)
                Button(action: {
                    viewModel.sortColumn = .name
                    viewModel.changeSort()
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
                    viewModel.sortColumn = .created
                    viewModel.changeSort()
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
            }
            .padding(.horizontal)
            .padding(.bottom, 0)
            .padding(.top, 20)
            .font(.headline)
            
            List {
                ForEach(viewModel.fileItems) { pfile in
                    FileItemRow(viewModel: viewModel, item: pfile, folderURL: viewModel.parentFolderURL)
                }.onDelete { indexSet in
                    itemsToDelete = indexSet
                    for (index) in (indexSet) {
                        viewModel.deleteFileName = viewModel.fileItems[index].name
                        if (Files.isSeedRecording(name: viewModel.deleteFileName!)) {
                            viewModel.displaySeedRecAlert = true
                        } else {
                            viewModel.displayDeleteAlert = true
                        }
                    }
                }
                
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Saved Performances")
            .padding(.bottom, 0)
            .navigationBarTitleDisplayMode(.inline)
            .font(.custom("HelveticaNeue-Light", size: 18))
        }
        .task {
            await viewModel.loadLibraryContents()
        }
        
        .alert("Delete recording?", isPresented: $viewModel.displayDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let indexSet = itemsToDelete {
                    viewModel.completeDelete(at: indexSet)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete the recording \"\(viewModel.deleteFileName ?? "")\"?")
        }
        .alert("Built-in performance", isPresented: $viewModel.displaySeedRecAlert) {
            Button("OK") { }
        } message: {
            Text("This performance is built-in to the app and cannot be deleted, renamed, or uploaded.")
        }
        .alert("Error", isPresented: $viewModel.displayGeneralAlert) {
            Button("OK") { }
        } message: {
            Text("An error occurred while attempting this operation. " + (viewModel.generalErrorMessage ?? ""))
        }
    }
}

struct FileItemRow: View {
    let viewModel: LV_ViewModel
    let item: PFileItem
    let folderURL: URL
    
    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            Text(item.name)
                .font(.subheadline)
                .frame(minWidth: 220, maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 50)
            let displayableDate = item.creationDate.formatted(date: .numeric, time: .omitted)
            Text("\(displayableDate)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 100, maxWidth: .infinity, alignment: .trailing)
            let pURL = (Files.isSeedRecording(name: item.name)) ?
            Files.seedRecordingURL() : folderURL.appendingPathComponent(item.name)
            NavigationLink(destination: LibraryMapView(viewModel: viewModel, parentFolderURL: folderURL, performanceURL: pURL)){}
            Spacer()
        }
    }
}

