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
    @EnvironmentObject var deletionManager: DeletionManager
    
    static var originPoint: [Entity]  = []
    
    // List containing currently active models
    // TODO: Logic for keeping this list updated? 
    static var activeModels: [ModelEntity] = []
    static var anchorEntities: [AnchorEntity] = []
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, deletionManager: deletionManager)
        
        // Subscribe to sceneEvents.update
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
                self.placeFloor(in: arView, for: self.placementSettings.originfloor!)
            } else {
                self.place(for : confirmedModel, in: arView)
                
                for child in confirmedModel.childs {
                    print(child.name)
                    self.place(for: child, in: arView)
                }
            }
            self.placementSettings.confirmedModel = nil
            self.placementSettings.originfloor = false
        }
    }
    
    private func place(for model: Model, in arView: ARView) {
       
        let modelEntity = ModelLibrary().getModelEntity(for: model)
        
//        testing if setPosition works
//        print("hard coding to test get realtive position")
//        modelEntity.setPosition(SIMD3<Float>(0.008482501, 0.0, 0.00525086), relativeTo: ARSceneManager.originPoint[0])
        
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
        ARSceneManager.activeModels.append(modelEntity)
        ARSceneManager.anchorEntities.append(anchorEntity)
        print("added modelEntity")
        
        //testing is getrelativepostiion works
//        ModelLibrary().getRelativePosition(from: modelEntity, to: ARSceneManager.originPoint[0])
        
    }
    
    // fun place floor in arview container
    private func placeFloor(in arView: ARView, for setOrigin: Bool) {
        let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [SimpleMaterial()])
        floor.generateCollisionShapes(recursive: true)
        floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        floor.components[ModelComponent.self] = nil
        
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(floor)
        
        arView.scene.addAnchor(anchorEntity)
        
        // set origion point
        if setOrigin == true {
            ARSceneManager.originPoint.append(floor)
            print("set origin point")
        }
        
        print("added floor")
    }
}
