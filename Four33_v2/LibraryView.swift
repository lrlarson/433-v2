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

    @State private var sortOrder: SortOrder = .dateDescending   // default: sort newest first

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
                Button(action: {
                    toggleSort(by: .name)
                }) {
                    HStack {
                        Text("Name")
                        Image(systemName: sortOrder == .nameAscending ? "arrow.down" : (sortOrder == .nameDescending ? "arrow.up" : ""))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    toggleSort(by: .created)
                }) {
                    HStack {
                        Text("Created")
                        Image(systemName: sortOrder == .dateAscending ? "arrow.down" : (sortOrder == .dateDescending ? "arrow.up" : ""))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .font(.headline)

            List(sortedItems) { file in
                HStack() {
                    Text(file.name)
                        .font(.headline)
                    Spacer()
                    Text("\(file.creationDate.formatted(.dateTime))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Saved Performances")
                        .font(Font.headline)
                }
               ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {}
                }

            }
            .padding(.top, 1)
            .navigationBarTitleDisplayMode(.inline)
            .font(.custom("HelveticaNeue-Light", size: 18))
            .onAppear(perform: loadFiles)
        }
    }
    
    func fileDeleted(at offsets: IndexSet) {
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
