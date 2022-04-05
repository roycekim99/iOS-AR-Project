//
//  ContentView.swift
//  TableTop
//
//  Created by Jet Aung on 1/26/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @State private var isControlsVisible: Bool = true
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    @State private var isZoomEnabled: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ARViewContainer()
            
            // If no model is selected for placement, show default UI
            if self.placementSettings.selectedModel == nil {
                ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings, isZoomEnabled: $isZoomEnabled)
            } else {
                // Show placement view
                PlacementView()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

class SceneManager: ObservableObject {
    @Published var modelEntities: [ModelEntity] = []
    @Published var floor = AnchorEntity()
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
            .environmentObject(ZoomView())
            .environmentObject(SceneManager())
    }
}


