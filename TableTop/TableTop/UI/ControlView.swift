//
//  ControlView.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import SwiftUI
import RealityKit
import ARKit

//show default UI
struct ControlView: View {
    @State private var isControlsVisible: Bool = true
    @State private var isZoomEnabled: Bool = false
    
    var body: some View {
            ZStack(alignment: .bottom) {
                ARViewContainer()
                DefaultView(isControlsVisible: $isControlsVisible, isZoomEnabled: $isZoomEnabled)
            }
            .edgesIgnoringSafeArea(.all)
    }
}

// UIViewRepresentable converts UIKit view to SwiftUI
// RealityKit view is UIKit view
struct ARViewContainer: UIViewRepresentable {
    // very basic makeUIView function
    // may need to modify later
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct DefaultView: View {
    @Binding var isControlsVisible: Bool
    @Binding var isZoomEnabled: Bool
    
    var body: some View {
        VStack {
        
            ControlTopBar(isControlsVisible: $isControlsVisible, isZoomEnabled: $isZoomEnabled)
            
            Spacer()
            
            if isControlsVisible {
                ControlBottomBar()
            }

        }
    }
}

struct ControlTopBar: View {
    @Binding var isControlsVisible: Bool
    @Binding var isZoomEnabled: Bool
    
    var body: some View {
        HStack {
            
            if self.isControlsVisible{
                ZoomButton(isZoomEnabled: $isZoomEnabled)
            }
            
            Spacer()
            
            ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible)
            
            
        }
        .padding(.top, 45)
    }
}

struct ControlVisibilityToggleButton: View {
    @Binding var isControlsVisible: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
            
            Button(action: {
                print("Control Visibility Toggle Button Pressed.")
                self.isControlsVisible.toggle()
            }) {
                Image(systemName: self.isControlsVisible ? "rectangle" : "slider.horizontal.below.rectangle")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
            
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8.0)
        .padding(.trailing, 100)
        
    }
}

struct ZoomButton: View {
    @Binding var isZoomEnabled: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
            
            Button(action: {
                print("Zoom Button Pressed.")
                self.isZoomEnabled.toggle()
            }) {
                Image(systemName: self.isZoomEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8.0)
        .padding(.leading, 100)
    }
}

struct ControlBottomBar: View {
    var body: some View {
        HStack {
            Spacer()
            
//             Browse Button
            ControlButton(systemIconName: "square.grid.2x2") {
                print("Browse button pressed")
            }
            
            Spacer()

            // Settings Button
            ControlButton(systemIconName: "slider.horizontal.3") {
                print("Settings button pressed")
            }
            
            Spacer()
            
        }
        .frame(minWidth: 500)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

struct ControlButton: View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size:35))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
    }
}


struct ControlView_Previews: PreviewProvider{
    static var previews: some View{
        ControlView()
    }
}
