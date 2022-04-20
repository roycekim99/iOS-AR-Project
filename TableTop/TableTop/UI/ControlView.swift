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
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var deletionManager: DeletionManager
    @State private var isControlsVisible: Bool = true
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    @State private var zoomEnabled: Bool = false
    @State private var deleteEnabled: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARSceneManager()
                
//          If no model is selected for placement, show default UI
            if self.placementSettings.selectedModel != nil {
                // Show placement view
                PlaceConfirmView()
            } else if self.deleteEnabled {
                DeletionView(deleteEnabled: $deleteEnabled)
            } else {
                DefaultView(isControlsVisible: $isControlsVisible,/* isZoomEnabled: $isZoomEnabled,*/ showBrowse: $showBrowse, showSettings: $showSettings, zoomEnabled: $zoomEnabled, deleteEnabled: $deleteEnabled)
            }
                
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct DefaultView: View {
    @Binding var isControlsVisible: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @Binding var zoomEnabled: Bool
    @Binding var deleteEnabled: Bool
    
    var body: some View {
        VStack {
        
            ControlTopBar(isControlsVisible: $isControlsVisible, zoomEnabled: $zoomEnabled, deleteEnabled: $deleteEnabled)
            
            Spacer()
            
            if (isControlsVisible && !zoomEnabled){
                ControlBottomBar(showBrowse: $showBrowse, showSettings: $showSettings)
            }

        }
    }
}

struct ControlTopBar: View {
    @Binding var isControlsVisible: Bool
    @Binding var zoomEnabled: Bool
    @Binding var deleteEnabled: Bool

    var body: some View {
        HStack {
            if isControlsVisible{
                ZoomButton(zoomEnabled: $zoomEnabled)
                    .environmentObject(ZoomView())
            }

            Spacer()
            if !zoomEnabled {
                ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible)
            }
        }
        .padding(.top, 45)
        
        HStack {
            Spacer()
            if (isControlsVisible && !zoomEnabled){
                DeletionButton(deleteEnabled: $deleteEnabled).environmentObject(DeletionManager())
            }
        }
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
        .padding(.trailing, 20)
    }
}

struct DeletionButton: View {
    @EnvironmentObject var deletion: DeletionManager
    @Binding var deleteEnabled: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
            
            Button(action: {
                print("Deletion Button Pressed.")
                self.deleteEnabled.toggle()
                self.deletion.DeletionEnabled = self.deleteEnabled
                CustomARView.resetAll(modelEntities: ARSceneManager.activeModels)
            }) {
                Image(systemName: self.deleteEnabled ? "trash.fill" : "trash")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8.0)
        .padding(.trailing, 20)
    }
}

struct ZoomButton: View {
    @EnvironmentObject var zoomView: ZoomView
    @Binding var zoomEnabled: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)

            Button(action: {
                print("Zoom Button Pressed.")
                self.zoomEnabled.toggle()
                //zoomView.ZoomEnabled.toggle()
                //zoomEnabled = zoomView.ZoomEnabled
                self.zoomView.ZoomEnabled = self.zoomEnabled
                CustomARView.moveAll(check: self.zoomView.ZoomEnabled, modelEntities: ARSceneManager.activeModels)
            }) {
                Image(systemName: self.zoomEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8.0)
        .padding(.leading, 20)
    }
}
 
struct ControlBottomBar: View {
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            
            MostRecentlyPlacedButton()
                        
            Spacer()
            
            // Browse Button
            ControlButton(systemIconName: "square.grid.2x2") {
                print("Browse button pressed")
                self.showBrowse.toggle()
            }.sheet(isPresented: $showBrowse) {
                BrowseView(showBrowse: $showBrowse)
            }
            
            Spacer()

            // Settings Button
            ControlButton(systemIconName: "slider.horizontal.3") {
                print("Settings button pressed")
                self.showSettings.toggle()
            }.sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
            }
                        
        }
        .frame(maxWidth: 500)
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

struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        Button(action: {
            print("Most Recently Placed button pressed")
            self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
        }) {
            if let mostRecentlyPlacedModel = self.placementSettings.recentlyPlaced.last {
                Image(uiImage: mostRecentlyPlacedModel.thumbnail)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.white)
        .cornerRadius(8.0)
    }
}


struct ControlView_Previews: PreviewProvider{
    static var previews: some View{
        ControlView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
            .environmentObject(DeletionManager())
    }
}
