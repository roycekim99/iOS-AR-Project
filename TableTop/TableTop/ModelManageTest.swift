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
    // [UID:Model]
    let activeModels: [String: Model] = [:]
    
    var targetARView: ARView
    var deletionManager: DeletionManager

    
    init(target: ARView, deletionManager: DeletionManager){
        self.targetARView = target
        self.deletionManager = deletionManager
        
        //DEBUG
        print("DEBUG:: ModelManager properly set up!!!")
    }
    
    //generic instantiation
    init(){
        self.targetARView = ARView()
        self.deletionManager = DeletionManager()
        
        //DEBUG
        print("DEBUG:: ModelManager lazily setup...")
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
        
    private func updateActiveModels(){
        
    }
        
}

