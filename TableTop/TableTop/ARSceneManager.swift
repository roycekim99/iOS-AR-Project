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
            
            if confirmedModel.name == "floor" {
                self.placeFloor(in: arView)
            } else {
                self.place(for : confirmedModel, in: arView)
                
                for chd in confirmedModel.childs {
                    print(chd.name)
                    self.place(for: chd, in: arView)
                }
            }
            self.placementSettings.confirmedModel = nil

        }
    }
    
    private func place(for model: Model, in arView: ARView){
       
        let modelEntity = ModelLibrary().getModelEntity(for: model)
        
        modelEntity.generateCollisionShapes(recursive: true)
        
        // Set physics and mass
        if let collisionComponent = modelEntity.components[CollisionComponent.self] as? CollisionComponent {
            modelEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 100, material: nil, mode: .dynamic)
        }
        
        arView.installGestures(.all, for: modelEntity).forEach { entityGesture in
            entityGesture.addTarget(arView, action: #selector(CustomARView.handleTranslation(sender:)))
        }

        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(modelEntity)

        arView.scene.addAnchor(anchorEntity)
        
        print("added modelEntity")
        
    }
    
    // fun place floor in arview container
    private func placeFloor(in arView: ARView) {
        let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [SimpleMaterial()])
        floor.generateCollisionShapes(recursive: true)
        floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        floor.components[ModelComponent.self] = nil
        
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(floor)
        
        arView.scene.addAnchor(anchorEntity)
        
        print("added floor")
    }
    
}
