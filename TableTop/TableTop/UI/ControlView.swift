//
//  ControlView.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import SwiftUI
import RealityKit
import ARKit
//import AlertToast

// MARK: ControlView_Main
struct ControlView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var deletionManager: DeletionManager
    @EnvironmentObject var serverServiceManager: ServerHandler
    
    @State private var isControlsVisible: Bool = true
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    @State private var zoomEnabled: Bool = false
    @State private var deleteEnabled: Bool = false
    @State private var showPlayerList = false
    
    @State private var showUsernameView = true
    @State private var showStartView = false
    @State private var userName = ""
    
    @State private var showMessage = false
    @State private var message = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if self.showUsernameView {
                UserNameView(userName: $userName, showStartView: $showStartView, showUsernameView: $showUsernameView)
            } else if self.showStartView {
                StartView(showStartView: $showStartView, showUsernameView: $showUsernameView)
            } else {
                ARSceneContainer()
                    
    //          If no model is selected for placement, show default UI
                if self.placementSettings.selectedModel != nil {
                    // Show placement view
                    PlaceConfirmView(isOrigin: self.placementSettings.originfloor!)
                } else if self.deleteEnabled {
                    DeletionView(deleteEnabled: $deleteEnabled)
                } else {
                    DefaultView(isControlsVisible: $isControlsVisible,/* isZoomEnabled: $isZoomEnabled,*/ showBrowse: $showBrowse, showSettings: $showSettings, zoomEnabled: $zoomEnabled, deleteEnabled: $deleteEnabled, showStartView: $showStartView, showPlayerList: $showPlayerList)
                }
            }
           
        }
        .edgesIgnoringSafeArea(.all)
    }

}

// MARK: Default View
struct DefaultView: View {
    @Binding var isControlsVisible: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @Binding var zoomEnabled: Bool
    @Binding var deleteEnabled: Bool
    @Binding var showStartView: Bool
    @Binding var showPlayerList: Bool
    
    var body: some View {
        VStack {
        
            ControlTopBar(isControlsVisible: $isControlsVisible, zoomEnabled: $zoomEnabled, deleteEnabled: $deleteEnabled, showStartView: $showStartView)
            
            Spacer()
            
            if (isControlsVisible && !zoomEnabled){
                ControlBottomBar(showBrowse: $showBrowse, showSettings: $showSettings, showPalyerList: $showPlayerList)
            }

        }
    }
}

// MARK: ControlView_Previews
struct ControlView_Previews: PreviewProvider{
    static var previews: some View{
        ControlView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
            .environmentObject(DeletionManager())
            .environmentObject(ServerHandler())
    }
}

// MARK: ControlTopBar
struct ControlTopBar: View {
    @Binding var isControlsVisible: Bool
    @Binding var zoomEnabled: Bool
    @Binding var deleteEnabled: Bool
    @Binding var showStartView: Bool

    var body: some View {
        VStack {
            HStack {
                if isControlsVisible {
                    BackButton(showStartView: $showStartView)
                }

                Spacer()
                if !zoomEnabled {
                    ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible)
                }
            }
            .padding(.top, 45)
            
            HStack {
                if isControlsVisible{
                    ZoomButton(zoomEnabled: $zoomEnabled)
                        .environmentObject(ZoomView())
                }
                Spacer()
                if (isControlsVisible && !zoomEnabled){
                    DeletionButton(deleteEnabled: $deleteEnabled).environmentObject(DeletionManager())
                }
            }
        }
   
    }
}

// MARK: ControlVisibilityToggleButton
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

// MARK: DelectionButton
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
                ModelManager.getInstance().resetAll()
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

// MARK: ZoomButton
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
                ModelManager.getInstance().moveAll(check: self.zoomView.ZoomEnabled)
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

// MARK: from arview back to homescreen
struct BackButton: View {
    @Binding var showStartView: Bool
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
            
            Button(action: {
                print("Back Button Pressed.")
                
                //remove all model in game
                for (_,model) in ModelManager.getInstance().activeModels {
                    let anchorEntity = model.getAnchorEntity()
                    print("DEBUG:: Deleting anchorEntity with id: \(model.name)")
                    
                    anchorEntity.removeFromParent()
                    anchorEntity.children.removeAll()
                }
                
                ModelManager.getInstance().clearActiveModels()
                placementSettings.reset()
                
                self.showStartView.toggle()
            }) {
                Image(systemName: "arrowshape.turn.up.left")
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
 
// MARK: Control Bottom Bar
struct ControlBottomBar: View {
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @Binding var showPalyerList: Bool

    
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
            
            Spacer()
            
            ControlButton(systemIconName: "book") {
                print("PlayerList button pressed")
                self.showPalyerList.toggle()
            }
            .sheet(isPresented: $showPalyerList) {
                PlayerListView(showPlayerList: $showPalyerList)
            }
                        
        }
        .frame(maxWidth: 500)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

// MARK: PlayerListview
struct PlayerListView: View {
    @Binding var showPlayerList: Bool
    
    let names = ["hfaje", "thoea hjka", "fhefewafe", "fnekfnefd", "bcndnvf", "mcsoj", "ndjnia", "njedknei", "mnkfeogkg", "gdkmeklnk"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(0..<names.count) { i in
                    VStack{
                        Text(names[i])
                            .padding(5)
                    }
                    
                }
            }
        }
        .navigationBarItems(leading:
            Button(action: {
            self.showPlayerList.toggle()
        }) {
            Text("Done").bold()
        })
    }
}

// MARK: Control Button
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

// MARK: Most Recently Placed Button
struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        Button(action: {
            print("DEBUG::Most Recently Placed button pressed")
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

