//
//  ARViewContainer.swift
//  TableTop
//
//  Created by Jet Aung on 4/5/22.
//

import Foundation
import SwiftUI
import RealityKit
struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @EnvironmentObject var zoom: ZoomView
    @EnvironmentObject var sceneManager: SceneManager
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings, zoom: zoom, sceneManager: sceneManager, placementSettings: placementSettings)
        
        // Subscribe to SceneEvents.Update
        // Check every frame for updates from the scene if object is placed, deleted, moved, etc.
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            self.updateScene(for: arView)
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
            
            if confirmedModel.name != "floor" {
                self.place(modelEntity, in: arView)
                // After creating children variable to Model
                for chd in confirmedModel.childs {
                    print(chd.name)
                    self.place(chd.modelEntity!, in: arView)
                }
                self.placementSettings.confirmedModel = nil
            } else {
                self.placeFloor(modelEntity, in: arView)
                self.placementSettings.confirmedModel = nil
            }
        }
    }
    
    private func placeFloor(_ modelEntity: ModelEntity, in arView: CustomARView) {
        let floor = modelEntity.clone(recursive: true)
        floor.generateCollisionShapes(recursive: true)
        if let collisionComponent = floor.components[CollisionComponent.self] as? CollisionComponent {
            floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 0, material: nil, mode: .static)
            floor.components[ModelComponent.self] = nil // make the floor invisible
        }
        
        floor.transform.translation.y += -50
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(floor)
        anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
        arView.scene.addAnchor(anchorEntity)

        print("added floor")
        
        sceneManager.floor = anchorEntity
    }
    
    private func place(_ modelEntity: ModelEntity, in arView: CustomARView) {
        
        let displayName = arView.multipeerHelp.myPeerID.displayName
        if let myData = "hello! from \(displayName)".data(using: .unicode) {
            arView.multipeerHelp.sendToAllPeers(myData, reliably: true)
        }
        
        // 1. Clone modelEntity. This creates an identical copy of modelEntity and references the same model. This also allows us to have multiple models of the same asset in our scene.
        let clonedEntity = modelEntity.clone(recursive: true)
        
        // 2. Enable gestures.
        clonedEntity.generateCollisionShapes(recursive: true)
        if let collisionComponent = clonedEntity.components[CollisionComponent.self] as? CollisionComponent {
            clonedEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 100, material: nil , mode:  .dynamic)
        }
        
        arView.installGestures(for: clonedEntity).forEach { entityGesture in
            entityGesture.addTarget(arView, action: #selector(CustomARView.transformObject(_:)))
        }
        
        self.sceneManager.modelEntities.append(clonedEntity)
        
        // 3. Create an anchorEntity and add clonedEntity to the anchorEntity
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
        
        // 4. Add the achorEntity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        print("Added modelEntity to scene.")
    }
    
    private func place(inputJSON: JSONData, _ arView: CustomARView){
        let nameFromJSON = inputJSON.modelName
        let requestedEntity = self.sceneManager.modelEntities.filter({$0.name == nameFromJSON })
        place(requestedEntity.first!, in: arView)
    }
    
    
    func moveAll( check: inout Bool, modelEntities: [ModelEntity]) {
        for ent in modelEntities {
            if check {
                ent.physicsBody?.mode = .kinematic
                ent.transform.translation.y += 0.01
                
            } else {
                ent.transform.translation.y += -0.01
                ent.physicsBody?.mode = .dynamic
            }
        }
    }
}
