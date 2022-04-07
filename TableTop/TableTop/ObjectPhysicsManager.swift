//
//  ObjectPhysicsManager.swift
//  TableTop
//
//  Created by Jet Aung on 4/7/22.
//
/*
Abstract:
Allows the changing of model physics mode depending on the gesture
 */

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import MultipeerHelper
import MultipeerConnectivity
import Combine

// Add functionality to switch object physics body in order to move objects
extension CustomARView {
    
    func moveObject() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func transformObject(_ sender: UIGestureRecognizer) {
        
        //if self.zoom.ZoomEnabled {
            if let transformGesture = sender as? EntityTranslationGestureRecognizer {
                //print(startPos)
                var endPos: SIMD3<Float>
                var difference: SIMD3<Float>
                if self.zoom.ZoomEnabled {

                    if self.objectMoved == nil {
                        self.objectMoved = transformGesture.entity!
                    } else if (transformGesture.entity! != self.objectMoved) {
                        return
                    }
                }
                switch transformGesture.state {
                case .began:
                    print("Started Moving")
                    
                    startPos = transformGesture.entity!.position
                    
                    
                    
                    ///
                    if self.zoom.ZoomEnabled {

                        for ent in self.sceneManager.modelEntities {
                            if (ent != transformGesture.entity!) {
                                self.anchorMap[ent] = ent.parent as? AnchorEntity
                                
                                ent.setParent(transformGesture.entity, preservingWorldTransform: true)
                            }
                        }
                    }
                case .ended:
                    print(self.anchorMap.count)
                    endPos = transformGesture.entity!.position
                    difference = endPos - startPos
                    print("Start: \(startPos)")
                    print("End: \(endPos)")
                    print("Difference \(difference)")
                    
                    
                    if self.zoom.ZoomEnabled {

                        for ent in self.sceneManager.modelEntities {
                            if (ent != transformGesture.entity!) {
                                ent.setParent(self.anchorMap[ent], preservingWorldTransform: true)
                            }
                        }
                    }
                    self.anchorMap.removeAll()
                    print("Stopped Moving")
                    self.objectMoved = nil
                default:
                    return
                }
            }
        //}
        
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("LongPressed")

        let location = sender.location(in: self)
        print(lockedEntities)
        if let entity = self.entity(at: location) as? ModelEntity {
            if sender.state == .began {
                /*
                if entity.physicsBody?.mode != .static {
                    entity.physicsBody?.mode = .static
                    print("Set to static.")
                    
                } else {
                    entity.physicsBody?.mode = .dynamic
                    print("Set to dynamic")
                }*/
                if lockedEntities.contains(entity) {
                    entity.physicsBody?.mode = .dynamic
                    entity.transform.translation.y += 0.005
                    for i in lockedEntities.indices {
                        if lockedEntities[i] == entity {
                            lockedEntities.remove(at: i)
                        }
                    }
                } else {
                    entity.physicsBody.self?.mode = .static
                    entity.transform.translation.y += -0.005
                    //let recognizerIndex = gestureRecognizers?.firstIndex(of: sender)
                    //gestureRecognizers?.remove(at: recognizerIndex!)
                    print("locking entity")
                    lockedEntities.append(entity)
                }
            }
        }
    }
    
    // Tap object to switch physics body mode
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        var isStacked: Bool = false
        var height: Float = 0
        
        let location = recognizer.location(in: self)
        //print(focusEntity?.position)
        /*
        let frameSize: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height*0.5)
        print(frameSize)
         */
        if self.placementSettings.selectedModel != nil {
            if self.placementSettings.selectedModel!.name != "floor" {
                if let entity = self.entity(at: location) as? ModelEntity {
                    if self.sceneManager.modelEntities.contains(entity) {
                        isStacked = true
                        height = entity.transform.translation.y
                        print("we stacking")
                    }
                }
                let modelEntity = self.placementSettings.selectedModel?.modelEntity
                if let result = self.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
                    let arAnchor = ARAnchor(transform: result.worldTransform)
                let clonedEntity = modelEntity?.clone(recursive: true)
                clonedEntity?.generateCollisionShapes(recursive: true)
                if let collisionComponent = clonedEntity?.components[CollisionComponent.self] as? CollisionComponent {
                    clonedEntity?.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 100, material: nil , mode: .dynamic)
                }
                self.installGestures(for: clonedEntity!).forEach { entityGesture in
                    entityGesture.addTarget(self, action: #selector(self.transformObject(_:)))
                }
                self.sceneManager.modelEntities.append(clonedEntity!)
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(clonedEntity!)
                    if isStacked {
                        clonedEntity?.transform.translation.y += 0.03 + height
                    }
                clonedEntity?.transform.translation.y += 0.03
                anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
                anchorEntity.anchoring = AnchoringComponent(arAnchor)
                self.scene.addAnchor(anchorEntity)
                self.session.add(anchor: arAnchor)
                }
                /*
                let children = self.placementSettings.selectedModel?.childs
                for chd in children ?? [] {
                    let result = self.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first
                    let arAnchor = ARAnchor(transform: result!.worldTransform)
                    let chdClone = chd.modelEntity?.clone(recursive: true)
                    chdClone?.generateCollisionShapes(recursive: true)
                    if let collisionComponent = chdClone?.components[CollisionComponent.self] as? CollisionComponent {
                        chdClone?.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 100, material: nil , mode: .dynamic)
                    }
                    self.installGestures(for: chdClone!).forEach { entityGesture in
                        entityGesture.addTarget(self, action: #selector(self.transformObject(_:)))
                    }
                    
                    let chdAnchorEntity = AnchorEntity(plane: .any)
                    chdAnchorEntity.synchronization?.ownershipTransferMode = .autoAccept
                    chdAnchorEntity.anchoring = AnchoringComponent(arAnchor)
                    self.scene.addAnchor(chdAnchorEntity)
                    self.session.add(anchor: arAnchor)
                    
                }*/
                
                
                // 3. Create an anchorEntity and add clonedEntity to the anchorEntity
            } else {
                let floor = self.placementSettings.selectedModel!.modelEntity?.clone(recursive: true)
                if let result = self.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
                    let arAnchor = ARAnchor(transform: result.worldTransform)
                    floor?.generateCollisionShapes(recursive: true)
                    if let collisionComponent = floor?.components[CollisionComponent.self] as? CollisionComponent {
                        floor?.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 0, material: nil, mode: .static)
                        floor?.components[ModelComponent.self] = nil // make the floor invisible
                    }
                    
                    floor?.transform.translation.y += -50
                    let anchorEntity = AnchorEntity(plane: .any)
                    anchorEntity.addChild(floor!)
                    anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
                        anchorEntity.anchoring = AnchoringComponent(arAnchor)
                    self.scene.addAnchor(anchorEntity)
                    self.session.add(anchor: arAnchor)
                    print("added floor")
                    
                    sceneManager.floor = anchorEntity
                }
            }
        }
        
        else if let entity = self.entity(at: location) as? ModelEntity {
            if !entity.isOwner {
                entity.requestOwnership { result in
                    if result == .granted {
                        print("entity ownership being transferred")
                        /*if entity.physicsBody.self?.mode == .dynamic {
                            // Start moving
                            entity.physicsBody.self?.mode = .kinematic
                            entity.transform.translation.y += 0.01
                        } else {
                            // Finished moving
                            entity.physicsBody.self?.mode = .dynamic
                        }*/
                    }
                    
                }
            }
            if !lockedEntities.contains(entity) {
                if entity.physicsBody.self?.mode == .dynamic {
                    // Start moving
                    print("to kinematic")
                    entity.physicsBody.self?.mode = .kinematic
                    entity.transform.translation.y += 0.01
                } else {
                    // Finished moving
                    print("to dynamic")
                    entity.physicsBody.self?.mode = .dynamic
                }
            }
        }
    }
}
