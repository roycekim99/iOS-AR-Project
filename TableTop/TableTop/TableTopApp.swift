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
    
    var body: some Scene {
        WindowGroup {
            ControlView()
                .environmentObject(placementSettings)
        }
    }
}
