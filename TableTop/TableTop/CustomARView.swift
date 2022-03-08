//
//  CustomARView.swift
//  TableTop
//
//  Created by Jet Aung on 2/2/22.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import Combine

// CustomARView: Implements FocusEntity for object placement, people/object occlusion, lidar visualization, and tap response functionality
class CustomARView: ARView {
    var objectMoved: Entity? = nil
    var zoom: ZoomView
    var sceneManager: SceneManager
    var focusEntity: FocusEntity?
    var sessionSettings: SessionSettings
    var anchorMap = [ModelEntity:AnchorEntity]()
    var startPos: SIMD3<Float>
    
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, zoom: ZoomView, sceneManager: SceneManager) {
        self.sessionSettings = sessionSettings
        
        self.zoom = zoom
        
        self.sceneManager = sceneManager
        
        self.startPos = SIMD3<Float>(0,0,0)

        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
                
        configure()
        
        self.initializeSettings()
        
        self.setupSubscribers()
        
        self.moveObject()
        
        
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        session.run(config)
    }
    
    private func initializeSettings() {
        self.updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        self.updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        self.updateLidarDebug(isEnabled: sessionSettings.isLidarDebugEnabled)
        self.updateMultiuser(isEnabled: sessionSettings.isMultiuserEnabled)
    }
    // Set up subscribers to state variables
    private func setupSubscribers() {
        self.peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled )
        }
        
        self.objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled )
        }
        
        self.lidarDebugCancellable = sessionSettings.$isLidarDebugEnabled.sink { [weak self] isEnabled in
            self?.updateLidarDebug(isEnabled: isEnabled )
        }
        
        self.multiuserCancellable = sessionSettings.$isMultiuserEnabled.sink { [weak self] isEnabled in
            self?.updateMultiuser(isEnabled: isEnabled )
        }
    }
    
    // Add functionality for people/object occlusion and lidar visualization
    
    private func updatePeopleOcclusion(isEnabled: Bool) {
        print("\(#file): isPeopleOcclusionEnabled is now \(isEnabled)")
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            return
        }
        guard let configuration = self.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        if configuration.frameSemantics.contains(.personSegmentationWithDepth) {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        } else {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        self.session.run(configuration)
    }
    
    private func updateObjectOcclusion(isEnabled: Bool) {
        print("\(#file): isObjectOcclusionEnabled is now \(isEnabled)")
        
        if self.environment.sceneUnderstanding.options.contains(.occlusion) {
            self.environment.sceneUnderstanding.options.remove(.occlusion)
        } else {
            self.environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    private func updateLidarDebug(isEnabled: Bool) {
        print("\(#file): isLidarDebugEnabled is now \(isEnabled)")
        
        if self.debugOptions.contains(.showSceneUnderstanding) {
            self.debugOptions.remove(.showSceneUnderstanding)
        } else {
            self.debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    // Not implemented. Copied from Reality School playlist. Will probably remove
    private func updateMultiuser(isEnabled: Bool) {
        print("\(#file): isMultiuserEnabled is now \(isEnabled)")
    }
    
    
}

// Add functionality to switch object physics body in order to move objects
extension CustomARView {
    
    func testing() {
        if self.zoom.ZoomEnabled {
            print("nice")
        } else {
            print("cool")
        }
    }
    
    func moveObject() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGesture)
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
                    print("")
                    print(difference)
                    
                    
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
    // Tap object to switch physics body mode
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        let location = recognizer.location(in: self)
        //print(focusEntity?.position)
        
        if let entity = self.entity(at: location) as? ModelEntity {
            
            if entity.physicsBody.self?.mode == .dynamic {
                // Start moving
                entity.physicsBody.self?.mode = .kinematic
                entity.transform.translation.y += 0.01
            } else {
                // Finished moving
                entity.physicsBody.self?.mode = .dynamic
            }
        }
    }
}
