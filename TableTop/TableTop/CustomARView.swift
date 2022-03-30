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
import MultipeerHelper
import MultipeerConnectivity
import Combine

// CustomARView: Implements FocusEntity for object placement, people/object occlusion, lidar visualization, and tap response functionality
class CustomARView: ARView, ARSessionDelegate/*, MCSessionDelegate, MCBrowserViewControllerDelegate*/{
    
    var multipeerHelp: MultipeerHelper!
    
    var objectMoved: Entity? = nil
    var zoom: ZoomView
    var sceneManager: SceneManager
    var focusEntity: FocusEntity?
    var sessionSettings: SessionSettings
    var anchorMap = [ModelEntity:AnchorEntity]()
    var startPos: SIMD3<Float>
    var placementSettings: PlacementSettings
    var lockedEntities = [ModelEntity]()
    
    /*
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiser: MCAdvertiserAssistant!
    */
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, zoom: ZoomView, sceneManager: SceneManager, placementSettings: PlacementSettings) {
        self.sessionSettings = sessionSettings
        
        self.zoom = zoom
        
        self.sceneManager = sceneManager
        
        self.startPos = SIMD3<Float>(0,0,0)
        
        self.placementSettings = placementSettings

        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
                
        configure()
        
        setupMultipeer()
        
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
        self.session.delegate = self
        let config = ARWorldTrackingConfiguration()
        config.isCollaborationEnabled = true
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
                    entity.transform.translation.y += 0.01
                    for i in lockedEntities.indices {
                        if lockedEntities[i] == entity {
                            lockedEntities.remove(at: i)
                        }
                    }
                } else {
                    entity.physicsBody.self?.mode = .static
                    entity.transform.translation.y += -0.01
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

extension CustomARView: MultipeerHelperDelegate {
    
    func shouldSendJoinRequest(_ peer: MCPeerID, with discoveryInfo: [String : String]?) -> Bool {
        if CustomARView.checkPeerToken(with: discoveryInfo) {
            return true
        }
        print("incompatible peer!")
        return false
    }
    
    func setupMultipeer() {
        multipeerHelp = MultipeerHelper(
            serviceName: "helper-test",
            sessionType: .both,
            delegate: self
        )
        
        // MARK: - Setting RealityKit Synchronization
        
        guard let syncService = multipeerHelp.syncService else {
            fatalError("could not create multipeerHelp.syncService")
        }
        self.scene.synchronizationService = syncService
    }
    
    func receivedData(_ data: Data, _ peer: MCPeerID) {
        print(String(data: data, encoding: .unicode) ?? "Data is not a unicode string")
    }
    
    func peerJoined(_ peer: MCPeerID) {
        print("new peer has joined:")
    }
}
