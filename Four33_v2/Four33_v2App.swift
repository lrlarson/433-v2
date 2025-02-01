//
//  Four33_v2App.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/19/24.
//

import SwiftUI

@main
struct Four33_v2App: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
//        let screet = FileUtils.buildFullTempURL(movement: "Two")
//        print("buildFullTempURL test: ", screet)
//        
//        let grook = FileUtils.buildFullDocsURL(recordingName: "Ploobis", movement: "Two")
//        print("buildFullDocsURL test: ", grook)
        
//        var url = Bundle.main.url(forResource:"metadata", withExtension: nil, subdirectory: "Seed_Recording")
//        var md = FileUtils.readMetaDataFromURL(url: url!)
//        md!.title = "Go Jump in a Lake"
//        
//        // Test: write metadata to outer docs folder
//        var isDirectory = ObjCBool(true)
//        let testurl:URL = FileUtils.getDocumentsDirURL()
//            .appending(path: "Grelgus", directoryHint: URL.DirectoryHint.isDirectory)
//        if (!FileManager.default.fileExists(atPath: testurl.path))
//        {
//            let success = FileUtils.createRecordingDir(url: testurl)
//            print("Directory creation success: ", success)
//        }
//        
//        url = FileUtils.getDocumentsDirURL()
//                .appending(path: "Grelgus", directoryHint: URL.DirectoryHint.isDirectory )
//                .appending(path:"metadata", directoryHint: URL.DirectoryHint.notDirectory)
//        print("Metadata write test URL: ", url!.absoluteString)
//        let success = FileUtils.writeMetadataToURL(url:url!, metadata: md!)
//        print ("Metadata write success: ", success)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase, initial: false) {
            // Monitoring the app's lifecycle changes
            /*
            switch scenePhase {
            case .active:
                print("App is active")
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is in the background")
            @unknown default:
                print("Unknown state")
            }
            */
        }
    }
}
