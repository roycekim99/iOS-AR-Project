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
import MultipeerConnectivity
import UIKit

// CustomARView: Implements FocusEntity for object placement, people/object occlusion, lidar visualization, and tap response functionality
class CustomARView: ARView {
    var objectMoved: Entity? = nil
    var zoom: ZoomView
    var sceneManager: SceneManager
    var focusEntity: FocusEntity?
    var sessionSettings: SessionSettings
    var anchorMap = [ModelEntity:AnchorEntity]()
    
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    @IBOutlet weak var messageLabel: MessageLabel?
    var multipeerSession: MultipeerSession?
    let coachingOverlay = ARCoachingOverlayView()
    // A dictionary to map MultiPeer IDs to ARSession ID's.
    // This is useful for keeping track of which peer created which ARAnchors.
    var peerSessionIDs = [MCPeerID: String]()
    var sessionIDObservation: NSKeyValueObservation?
    var configuration: ARWorldTrackingConfiguration?
    
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, zoom: ZoomView, sceneManager: SceneManager) {
        self.sessionSettings = sessionSettings
        
        self.zoom = zoom
        
        self.sceneManager = sceneManager

        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
                
        configure()
        
        self.initializeSettings()
        
        self.setupSubscribers()
        
        self.moveObject()
        
        setupCoachingOverlay()
        
        sessionIDObservation = observe(\.self.session.identifier, options: [.new]) { object, change in
            print("SessionID changed to: \(change.newValue!)")
            // Tell all other peers about your ARSession's changed ID, so
            // that they can keep track of which ARAnchors are yours.
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        
        // Start looking for other players via MultiPeerConnectivity.
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData, peerJoinedHandler:
                                            peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        automaticallyConfigureSession = false
        configuration = ARWorldTrackingConfiguration()
        configuration?.planeDetection = [.horizontal, .vertical]
        
        configuration?.isCollaborationEnabled = true

        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration?.sceneReconstruction = .mesh
        }
        
        session.run(configuration!)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let participantAnchor = anchor as? ARParticipantAnchor {
                messageLabel?.displayMessage("Established joint experience with a peer.")
                // ...
                let anchorEntity = AnchorEntity(anchor: participantAnchor)
                
                let coordinateSystem = MeshResource.generateCoordinateSystemAxes()
                anchorEntity.addChild(coordinateSystem)
                
                let color = participantAnchor.sessionIdentifier?.toRandomColor() ?? .white
                let coloredSphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.03),
                                                materials: [SimpleMaterial(color: color, isMetallic: true)])
                anchorEntity.addChild(coloredSphere)
                
                self.scene.addAnchor(anchorEntity)
            } else if anchor.name == "Anchor for object placement" {
                // Create a cube at the location of the anchor.
                let boxLength: Float = 0.05
                // Color the cube based on the user that placed it.
                let color = anchor.sessionIdentifier?.toRandomColor() ?? .white
                let coloredCube = ModelEntity(mesh: MeshResource.generateBox(size: boxLength),
                                              materials: [SimpleMaterial(color: color, isMetallic: true)])
                // Offset the cube by half its length to align its bottom with the real-world surface.
                coloredCube.position = [0, boxLength / 2, 0]
                
                // Attach the cube to the ARAnchor via an AnchorEntity.
                //   World origin -> ARAnchor -> AnchorEntity -> ModelEntity
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(coloredCube)
                self.scene.addAnchor(anchorEntity)
            }
        }
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
    
    /// - Tag: DidOutputCollaborationData
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        if !multipeerSession.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
        } else {
            print("Deferred sending collaboration to later because there are no peers.")
        }
    }

    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            self.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                     offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 3 {
            // Do not accept more than four users in the experience.
            messageLabel?.displayMessage("A fifth peer wants to join the experience.\nThis app is limited to four users.", duration: 6.0)
            return false
        } else {
            return true
        }
    }
    /// - Tag: PeerJoined
    func peerJoined(_ peer: MCPeerID) {
        messageLabel?.displayMessage("""
            A peer wants to join the experience.
            Hold the phones next to each other.
            """, duration: 6.0)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
        
    func peerLeft(_ peer: MCPeerID) {
        messageLabel?.displayMessage("A peer has left the shared experience.")
        
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present the error that occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
//            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func resetTracking() {
        guard let configuration = self.session.configuration else { print("A configuration is required"); return }
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = self.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                self.session.remove(anchor: anchor)
            }
        }
    }
    
    private func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        let idString = self.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
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
        
        if self.zoom.ZoomEnabled {
            if let transformGesture = sender as? EntityTranslationGestureRecognizer {
                if self.objectMoved == nil {
                    self.objectMoved = transformGesture.entity!
                } else if (transformGesture.entity! != self.objectMoved) {
                    return
                }
                switch transformGesture.state {
                case .began:
                    print("Started Moving")
                    for ent in self.sceneManager.modelEntities {
                        if (ent != transformGesture.entity!) {
                            self.anchorMap[ent] = ent.parent as? AnchorEntity
                            
                            ent.setParent(transformGesture.entity, preservingWorldTransform: true)
                        }
                    }
                case .ended:
                    print(self.anchorMap.count)
                    
                    
                    for ent in self.sceneManager.modelEntities {
                        if (ent != transformGesture.entity!) {
                            ent.setParent(self.anchorMap[ent], preservingWorldTransform: true)
                        }
                    }
                    self.anchorMap.removeAll()
                    print("Stopped Moving")
                    self.objectMoved = nil
                default:
                    return
                }
            }
        }
        
        
        
    }
    // Tap object to switch physics body mode
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        print("ZoomView.ZoomEnabled = \(String(describing: self.zoom.ZoomEnabled.description))")
        
        
        let location = recognizer.location(in: self)
        
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
