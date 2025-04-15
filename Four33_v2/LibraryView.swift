//
//  LibraryView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/20/24.
//

import SwiftUI

struct LibraryView: View {
    let parentFolderURL: URL = Files.getDocumentsDirURL()
    @State private var folders: [String] = []
    @State private var selection = "Red"
    let colors = ["Red", "Green", "Blue", "Black", "Tartan"]
    @State private var isShowingPopover = true

    
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 26)!]
    }

    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    List(folders, id: \.self) { folder in
                        Text(folder)
                    }
                    .navigationTitle("Saved Performances")
                    .font(.title3)
                    .onAppear(perform: fetchFolders)
                    TabView {
                        Tab("Received", systemImage: "tray.and.arrow.down.fill") {
                            //ReceivedView()
                        }
                        Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
                            //SentView()
                        }
                        Tab("Account", systemImage: "person.crop.circle.fill") {
                            //AccountView()
                        }
                    }
                    
                }
            }
            .popover(isPresented: $isShowingPopover, content: {
                Picker("Select a paint color", selection: $selection) {
                    ForEach(colors, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .presentationCompactAdaptation(.popover)
            })
        }
    }

    private func fetchFolders() {
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: parentFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            folders = contents
                .filter { $0.hasDirectoryPath } // Ensure it's a folder
                .map { $0.lastPathComponent }
        } catch {
            print("Error fetching folders: \(error)")
        }
    }
}

/*
 struct FolderListView_Previews: PreviewProvider {
 static var previews: some View {
 LibraryView(parentFolderURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
 }
 }
 */
