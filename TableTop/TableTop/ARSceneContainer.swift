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
struct ARSceneContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var deletionManager: DeletionManager
    @EnvironmentObject var serverServiceManager: ServerHandler

    static var originPoint: [Entity]  = []
    
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
            }
            else {
                //DEBUG
                print("DEBUG:: ARSC|| confirmed model: \(confirmedModel.name)")
                self.place(for : confirmedModel, in: arView)
                ModelManager.getInstance().addActiveModel(modelID: confirmedModel.model_uid, model: confirmedModel)
                
                // NH - Not sure if this is the best place to emit model placement call
                var dataToEmit = SharedSessionData(objectID: confirmedModel.model_uid, modelName: confirmedModel.name, position: [0.0, 0.0])
                
                serverServiceManager.emitModelPlaced(data: dataToEmit)
            }
            self.placementSettings.confirmedModel = nil
            self.placementSettings.originfloor = false
        }
    }
    
    private func place(for model: Model, in arView: ARView) {
       
        //DEBUG
        print("DEBUG:: place started for \(model.name)! active models: \(ModelManager.getInstance().activeModels.count)")
        print("DEBUG:: ARSC|| Model cloned from library of size: \(ModelLibrary.availableAssets.count)")
        
        var selectedClonedModel = ModelLibrary().getModelCloned(from: model)
        arView.installGestures(.all, for: selectedClonedModel.getModelEntity()).forEach { entityGesture in
            entityGesture.addTarget(arView, action: #selector(ModelManager.getInstance().handleTranslation(_ :)))
        }
        

        // anchor based on focus entity
        var anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(selectedClonedModel.getModelEntity())
        selectedClonedModel.setAnchorEntity(&anchorEntity)
        
        arView.scene.addAnchor(anchorEntity)

        print("DEBUG:: ARSC|| Cloned model: \(selectedClonedModel.name)")

        for child in selectedClonedModel.childs {
            print("DEBUG:: going thorugh children for \(selectedClonedModel.name)..." + child.name)
            self.place(for: child, in: arView)
        }
        //testing is getrelativepostiion works
//        ModelLibrary().getRelativePosition(from: modelEntity, to: ARSceneManager.originPoint[0])
        
        ModelManager.getInstance().addActiveModel(modelID: selectedClonedModel.getModelUID(), model: selectedClonedModel)
        
        //DEBUG
        print("DEBUG:: ARSC||| place ending! active models: \(ModelManager.getInstance().activeModels.count)")
        for modelInstance in ModelManager.getInstance().activeModels {
            print("DEBUG:: ARSC||| place ENDED! active model name: \(modelInstance.value.name)")
        }
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
            ARSceneContainer.originPoint.append(floor)
            print("set origin point")
        }
        
        print("added floor")
    }
}
