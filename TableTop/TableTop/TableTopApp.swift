//
//  TableTopApp.swift
//  TableTop
//
//  Created by Jet Aung on 1/26/22.
//

import SwiftUI

@main
struct TableTopApp: App {
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    @StateObject var zoomView = ZoomView()
    @StateObject var sceneManager = SceneManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
                .environmentObject(zoomView)
                .environmentObject(sceneManager)
        }
    }
}
