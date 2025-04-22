//
//  LibraryView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//

import SwiftUI

struct LibraryView: View {
    let parentFolderURL: URL = Files.getDocumentsDirURL()
    
    struct FileItem: Identifiable {
        let id = UUID()
        let name: String
        let creationDate: Date
    }
    
    @State private var files: [FileItem] = []
    @State private var sortOrder: SortOrder = .dateDescending   // default sort: newest first
    @State private var displayDeleteAlert: Bool = false
    @State private var deleteURL : URL? = nil

    enum SortOrder {
        case nameAscending, nameDescending, dateAscending, dateDescending
    }
    
    var sortedItems: [FileItem] {
        switch sortOrder {
        case .nameAscending:
            return files.sorted { $0.name < $1.name }
        case .nameDescending:
            return files.sorted { $0.name > $1.name }
        case .dateAscending:
            return files.sorted { $0.creationDate < $1.creationDate }
        case .dateDescending:
            return files.sorted { $0.creationDate > $1.creationDate }
        }
    }
    

    init() {
    }

    var body: some View {
        
        NavigationStack {
            // Headers
            HStack {
                Spacer(minLength: 16)
                Button(action: {
                    toggleSort(by: .name)
                }) {
                    HStack {
                        Text("Name")
                        if (sortOrder == .nameAscending || sortOrder == .nameDescending) {
                            Image(systemName: sortOrder == .nameAscending ? "arrow.down" : "arrow.up")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button(action: {
                    toggleSort(by: .created)
                }) {
                    HStack {
                        Text("Created")
                        if (sortOrder == .dateAscending || sortOrder == .dateDescending) {
                            Image(systemName: sortOrder == .dateAscending ? "arrow.down" :  "arrow.up")
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

            List() {
                ForEach (sortedItems) { file in
                    HStack() {
                        Text(file.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(file.creationDate.formatted(date: .numeric, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: fileDeleted)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Saved Performances")
            .toolbar {
                EditButton()
            }
            .padding(.bottom, 0)
            .navigationBarTitleDisplayMode(.inline)
            .font(.custom("HelveticaNeue-Light", size: 18))
            .onAppear(perform: loadFiles)
            
            .alert("Delete recording?", isPresented: $displayDeleteAlert) {
                Button("OK", action: completeDelete)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete the recording \"\(deleteURL?.lastPathComponent ?? "")\"?")
            }
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
            loadFiles()
            } catch {
                print("Failed to delete file: /(error)")
            }
        }
    }

    func loadFiles() {
        let fileManager = FileManager.default

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: parentFolderURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
            
            let fileItems: [FileItem] = fileURLs.compactMap { url in
                if let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate {
                    return FileItem(name: url.lastPathComponent, creationDate: creationDate)
                } else {
                    return nil
                }
            }
            files = fileItems.sorted { $0.creationDate > $1.creationDate }
        } catch {
            print("Error reading folder: \(error.localizedDescription)")
        }
    }
    
    func toggleSort(by column: SortColumn) {
        switch column {
        case .name:
            sortOrder = (sortOrder == .nameAscending) ? .nameDescending : .nameAscending
        case .created:
            sortOrder = (sortOrder == .dateAscending) ? .dateDescending : .dateAscending
        }
    }

    enum SortColumn {
        case name, created
    }
}



/*
 struct FolderListView_Previews: PreviewProvider {
 static var previews: some View {
 LibraryView(parentFolderURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
 }
 }
 */
