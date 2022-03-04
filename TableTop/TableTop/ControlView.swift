//
//  ControlView.swift
//  TableTop
//
//  Created by Jet Aung on 2/1/22.
//

import SwiftUI

// View of the Control settings
struct ControlView: View {
    @Binding var isControlsVisible: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @Binding var isZoomEnabled: Bool
    @EnvironmentObject var zoomView: ZoomView
    
    var body: some View {
        VStack {
            
            ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible, isZoomEnabled: $isZoomEnabled)
            
            Spacer()
            
            if isControlsVisible {
                ControlButtonBar(showBrowse: $showBrowse, showSettings: $showSettings)
            }
        }
    }
    
}

// Hide control settings if button is pressed
struct ControlVisibilityToggleButton: View {
    @Binding var isControlsVisible: Bool
    @Binding var isZoomEnabled: Bool
    
    var body: some View {
        HStack {
            
            if self.isControlsVisible {
                ZoomButton(isZoomEnabled: $isZoomEnabled)
            }
            
            Spacer()
            
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
        }
        .padding(.top, 45)
        .padding(.trailing, 20)
    }
}

struct ZoomButton: View {
    @Binding var isZoomEnabled: Bool
    @EnvironmentObject var zoomView: ZoomView
    @EnvironmentObject var sceneManager: SceneManager
    var blah = ARViewContainer()
    
    var body: some View {
        HStack {
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("Zoom Button Pressed.")
                
                    self.isZoomEnabled.toggle()
                    self.zoomView.ZoomEnabled = self.isZoomEnabled
                    self.blah.moveAll(check: &self.isZoomEnabled, modelEntities: self.sceneManager.modelEntities)
                    
                }) {
                    Image(systemName: self.isZoomEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)
        }
        .padding(.leading, 20)
        
    }
}

struct ControlButtonBar: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool
    @Binding var showSettings:Bool
    
    var body: some View {
        HStack {
            
            // MostRecentlyPlaced Button
            MostRecentlyPlacedButton().hidden(self.placementSettings.recentlyPlaced.isEmpty)
            
            Spacer()
            
            // Browse Button
            ControlButton(systemIconName: "square.grid.2x2") {
                print("Browse button pressed")
                self.showBrowse.toggle()
            }.sheet(isPresented: $showBrowse, content: {
                // BrowseView
                BrowseView(showBrowse: $showBrowse)
            })
            
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
