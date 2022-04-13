//
//  ARSceneManager.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI


// UIViewRepresentable converts UIKit view to SwiftUI
// RealityKit view is UIKit view
struct ARSceneManager: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero)
        
        // subscribe to sceneEvents.update
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, {(event) in
           updateScene(for: arView)
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
            
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmedModel {
            self.place(for : confirmedModel, in: arView)
            
            for chd in confirmedModel.childs {
                print(chd.name)
                self.place(for: chd, in: arView)
            }
                
            self.placementSettings.confirmedModel = nil
//            self.placementSettings.confirmedModelID = nil
                
        }
    }
    
    private func place(for model: Model, in arView: ARView){
       
        let modelEntity = ModelLibrary().getModelEntity(for: model)
        
        modelEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation] ,for: modelEntity)

        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(modelEntity)

        arView.scene.addAnchor(anchorEntity)
        
        print("added modelEntity")
        
    }
    
    // fun place floor in arview container
    
    
}






