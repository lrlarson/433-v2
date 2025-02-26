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
