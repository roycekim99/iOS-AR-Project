//
//  ModelManager.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import RealityKit
import ARKit
import SwiftUI

extension CustomARView {
    struct Holder {
        static var anchorMap = [ModelEntity:AnchorEntity]()
        static var objectMoved: Entity? = nil
        static var zoomEnabled = false
        static var deletionEnabled = false
    }
    
    func handleObject() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        if (!Holder.deletionEnabled && !Holder.zoomEnabled) {
            handlePhysics(recognizer: recognizer)
        } else if (Holder.deletionEnabled && !Holder.zoomEnabled){
            handleDeletion(recognizer: recognizer)
        }
    }
    
    func handlePhysics(recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) as? ModelEntity {
            print(ModelLibrary.getRelativePosition(from: entity, to: ARSceneManager.originPoint[0]))
            if (!Holder.zoomEnabled) {
                if entity.physicsBody.self?.mode == .dynamic {
                    print("to kinematic")
                    entity.physicsBody.self?.mode = .kinematic
                    entity.transform.translation.y += 0.01
                } else if entity.physicsBody.self?.mode == .kinematic {
                    print("to dynamic")
                    entity.physicsBody.self?.mode = .dynamic
                }
            }
        }
    }
    
    func handleDeletion(recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) as? ModelEntity {
            if (ARSceneManager.activeModels.contains(entity)) {
            deletionManager.entitySelectedForDeletion = entity
            }
        }
    }
    
    static func moveAll(check: Bool, modelEntities: [ModelEntity]) {
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
    
    static func resetAll(modelEntities: [ModelEntity]) {
        for ent in modelEntities {
            ent.physicsBody?.mode = .dynamic
//            for mod in ent.children {
//                if let modd = mod as? ModelEntity {
//                    modd.physicsBody?.mode = .dynamic
//                }
//            }
        }
    }
    
    @objc func handleTranslation(sender: UIGestureRecognizer) {
        
        if let gesture = sender as? EntityTranslationGestureRecognizer {
            
            let modEnt = gesture.entity
        
            if Holder.objectMoved == nil {
                Holder.objectMoved = modEnt
            } else if (modEnt != Holder.objectMoved) {
                return
            }
            
            switch gesture.state {
            case .began:
                print("Started Moving")
                
                if (Holder.zoomEnabled) {
                    print("zoooom")
                    for ent in ARSceneManager.activeModels {
                        if (ent != modEnt!) {
                            Holder.anchorMap[ent] = ent.parent as? AnchorEntity
                            ent.setParent(modEnt, preservingWorldTransform: true)
                        }
                    }
                }
            case .ended:
                print("Stopped Moving")
                print(Holder.anchorMap.count)
                
                if (Holder.zoomEnabled) {
                    for ent in ARSceneManager.activeModels {
                        if (ent != modEnt!) {
                            ent.setParent(Holder.anchorMap[ent], preservingWorldTransform: true)
                        }
                    }
                }
                Holder.anchorMap.removeAll()
                Holder.objectMoved = nil
            default:
                return
            }
        }
    }
}
