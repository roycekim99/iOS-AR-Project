//
//  ModelManageTest.swift
//  TableTop
//
//  Created by Royce Kim on 5/7/22.
//
// This class controls all the active models in the scene.
// ModelManager is a singleton.

import RealityKit
import ARKit
import SwiftUI

class ModelManager{
    private static var MMInstance = ModelManager()
    
    var objectMoved: Entity? = nil
    var zoomEnabled = false
    var deletionEnabled = false
    
    // [UID:Model]
    var activeModels = [String: Model]()
    var floorModel: ModelEntity? = nil
    
    var targetARView: ARView
    var deletionManager: DeletionManager
    
    private init(target: ARView, deletionManager: DeletionManager){
        self.targetARView = target
        self.deletionManager = deletionManager
        
        //DEBUG
        print("DEBUG:: ModelManager properly set up!!!")
    }
    
    //generic instantiation
    private init(){
        self.targetARView = ARView()
        self.deletionManager = DeletionManager()
        
        //DEBUG
        print("DEBUG:: ModelManager lazily setup...")
    }
    
    static func getInstance() -> ModelManager{
        return MMInstance
    }
        
    
    
    func clearActiveModels() {
        print("DEBUG:: activeModels before clearing \(activeModels)")
        activeModels = [String: Model]()
        print("DEBUG:: reset activeModels \(activeModels)")
    }
    
    func setARView(targetView: ARView){
        self.targetARView = targetView
    }
    
    func setDeletionmanager(deletionManager: DeletionManager){
        self.deletionManager = deletionManager
    }
    
    func addActiveModel(modelID: String, model: Model){
        self.activeModels[modelID] = model
    }
    
    func addFloorModel(floor: ModelEntity) {
        self.floorModel = floor
    }
    
    func handlePhysics(recognizer:UITapGestureRecognizer, zoomIsEnabled: Bool) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity {
            print()
            
            switchPhysicsMode(for: selectedModel, zoomIsEnabled: zoomIsEnabled)
        }
    }
    
    func handleDeleteion(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity {
            self.deletionManager.entitySelectedForDeletion = selectedModel
            
        }
    }
    
    @objc func handleTranslation(_ sender: UIGestureRecognizer) {
        //DEBUG
        //print("DEBUG:: MMT|| STARTED TRANSLATION!!")
        guard let gesture = sender as? EntityTranslationGestureRecognizer else { return }
        
        let targetModelEntity = gesture.entity
        
    
        if self.objectMoved == nil {
            self.objectMoved = targetModelEntity
        } else if (targetModelEntity != self.objectMoved) {
            return
        }
            
        switch gesture.state {
        case .began:
            print("DEBUG::Started Moving")
                
            if (CustomARView.Holder.zoomEnabled) {
                print("DEBUG:: zoooom")
                for (_,modelObj) in self.activeModels {
                    //save current child parent relationship
                    CustomARView.Holder.anchorMap[modelObj.getModelUID()] = modelObj.getModelEntity().parent as? AnchorEntity
                    
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(targetModelEntity, preservingWorldTransform: true)
                    }
                }
            }
        case .ended:
            print("DEBUG::Stopped Moving")
            let model = getModelType(modEnt: targetModelEntity as! ModelEntity)
            
            print(model.name)
            print(Model.getRelativePosition(from: targetModelEntity as! ModelEntity, to: ARSceneContainer.originPoint[0]))
            
            if (CustomARView.Holder.zoomEnabled) {
                for (_,modelObj) in self.activeModels {
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(CustomARView.Holder.anchorMap[modelObj.getModelUID()], preservingWorldTransform: true)
                    }
                }
            }
            //self.anchorMap.removeAll()
            self.objectMoved = nil
                
        default:
            return
        }
        
    }
    
    func moveAll(check: Bool){
        for (_, modelObj) in activeModels {
            let tempModel = modelObj.getModelEntity()
            
            if check {
                tempModel.physicsBody?.mode = .kinematic
                tempModel.transform.translation.y += 0.01
            } else {
                tempModel.transform.translation.y += -0.01
                tempModel.physicsBody?.mode = .dynamic
            }
        }
    }
    
    func resetAll(){
        for (_, modelObj) in activeModels {
            let tempModel = modelObj.getModelEntity()
            tempModel.physicsBody?.mode = .dynamic
        }
    }
    
    // MARK: *private functions*
    private func switchPhysicsMode(for selectedModel: ModelEntity, zoomIsEnabled: Bool){
        
        if (!zoomIsEnabled) {
            if selectedModel.physicsBody.self?.mode == .dynamic {
                print("to kinematic")
                selectedModel.physicsBody.self?.mode = .kinematic
                selectedModel.transform.translation.y += 0.01
            } else if selectedModel.physicsBody.self?.mode == .kinematic {
                print("to dynamic")
                selectedModel.physicsBody.self?.mode = .dynamic
            }
        }
        
    }
    
    private func getModelType(modEnt: ModelEntity) -> Model {
        var model: AnyObject?
        for mod in ModelManager.getInstance().activeModels {
            if (mod.value.modelEntity == modEnt) {
                model = mod.value
            }
        }
        return model as! Model
    }
       
        
}

