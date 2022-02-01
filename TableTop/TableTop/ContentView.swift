//
//  ContentView.swift
//  TableTop
//
//  Created by Jet Aung on 1/26/22.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var isControlsVisible: Bool = true
    @State private var showBrowse: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ARViewContainer()
            
            ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        
        let arView = ARView(frame: .zero)
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
