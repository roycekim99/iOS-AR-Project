//
//  ModelManageTest.swift
//  TableTop
//
//  Created by Royce Kim on 5/7/22.
//

import RealityKit
import ARKit
import SwiftUI

class ModelManagerTester{
    private static var MMInstance = ModelManagerTester()
    
    var objectMoved: Entity? = nil
    var zoomEnabled = false
    var deletionEnabled = false
    
    // [UID:Model]
    var activeModels = [String: Model]()
    
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
    
    static func getInstance() -> ModelManagerTester{
        return MMInstance
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
    
    func handlePhysics(recognizer:UITapGestureRecognizer, zoomIsEnabled: Bool) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity {
            
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
        print("DEBUG:: MMT|| STARTED TRANSLATION!!")
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
            
            if (self.zoomEnabled) {
                print("DEBUG:: zoooom")
                for (_,modelObj) in self.activeModels {
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(targetModelEntity, preservingWorldTransform: true)
                    }
                }
            }
        case .ended:
            print("DEBUG::Stopped Moving")
            
            if (self.zoomEnabled) {
                for (_,modelObj) in self.activeModels {
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(targetModelEntity, preservingWorldTransform: true)
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
       
        
}

