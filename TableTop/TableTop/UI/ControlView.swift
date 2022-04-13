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
    @State private var isControlsVisible: Bool = true
    @State private var isZoomEnabled: Bool = false
    @State private var showbrowse: Bool = false
    @State private var isFloorPlaced: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARSceneManager()
                
//          If no model is selected for placement, show default UI
            if self.placementSettings.selectedModel == nil {
                DefaultView(isControlsVisible: $isControlsVisible, isZoomEnabled: $isZoomEnabled, showBrowse: $showbrowse )
            } else {
                // Show placement view
                PlaceConfirmView()
            }
                
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct DefaultView: View {
    @Binding var isControlsVisible: Bool
    @Binding var isZoomEnabled: Bool
    @Binding var showBrowse: Bool
    
    var body: some View {
        VStack {
        
            ControlTopBar(isControlsVisible: $isControlsVisible, isZoomEnabled: $isZoomEnabled)
//            ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible, isZoomEnabled: $isZoomEnabled)
            
            Spacer()
            
            if isControlsVisible {
                ControlBottomBar(showBrowse: $showBrowse)
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

//struct ControlVisibilityToggleButton: View {
//    @Binding var isControlsVisible: Bool
//    @Binding var isZoomEnabled: Bool
//
//    var body: some View {
//        HStack {
//
//            if self.isControlsVisible {
//                ZoomButton(isZoomEnabled: $isZoomEnabled)
//            }
//
//            Spacer()
//
//            ZStack {
//
//                Color.black.opacity(0.25)
//
//                Button(action: {
//                    print("Control Visibility Toggle Button Pressed.")
//                    self.isControlsVisible.toggle()
//                }) {
//                    Image(systemName: self.isControlsVisible ? "rectangle" : "slider.horizontal.below.rectangle")
//                        .font(.system(size: 25))
//                        .foregroundColor(.white)
//                        .buttonStyle(PlainButtonStyle())
//                }
//            }
//            .frame(width: 50, height: 50)
//            .cornerRadius(8.0)
//        }
//        .padding(.top, 45)
//        .padding(.trailing, 20)
//    }
//}
//
//struct ZoomButton: View {
//    @Binding var isZoomEnabled: Bool
////    @EnvironmentObject var zoomView: ZoomView
////    @EnvironmentObject var sceneManager: SceneManager
//    var arView = ARViewContainer()
//
//    var body: some View {
//        HStack {
//            ZStack {
//                Color.black.opacity(0.25)
//
//                Button(action: {
//                    print("Zoom Button Pressed.")
//
////                    self.isZoomEnabled.toggle()
////                    self.zoomView.ZoomEnabled = self.isZoomEnabled
////                    self.arView.moveAll(check: &self.isZoomEnabled, modelEntities: self.sceneManager.modelEntities)
//
//                }) {
//                    Image(systemName: self.isZoomEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass")
//                        .font(.system(size: 25))
//                        .foregroundColor(.white)
//                        .buttonStyle(PlainButtonStyle())
//                }
//            }
//            .frame(width: 50, height: 50)
//            .cornerRadius(8.0)
//        }
//        .padding(.leading, 20)
//    }
//}

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
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool
    
    var body: some View {
        HStack {

            Spacer()
            
            MostRecentlyPlacedButton()
                        
            Spacer()
            
//             Browse Button
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
    }
}
