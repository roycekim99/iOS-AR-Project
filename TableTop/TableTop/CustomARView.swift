// An ARView instance which handles instantiation of a new ARView with a FocusEntity

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import Combine

class CustomARView: ARView {
    
    // MARK: FocusEntity -Start-
    var focusEntity: FocusEntity?
    var deletionManager: DeletionManager
    var sessionSettings: SessionSettings
    
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    
    required init(frame frameRect: CGRect, deletionManager: DeletionManager, sessionSettings: SessionSettings) {
        self.deletionManager = deletionManager
        self.sessionSettings = sessionSettings
        super.init(frame: frameRect)
        
        configure()
        
        self.initializeSettings()
        self.setupSubscribers()
    }
    
    private func configure() {
        focusEntity = FocusEntity(on: self, focus: .classic)
        ModelManager.getInstance().setARView(targetView: self)
        
        //DEBUG
        print("DEBUG:: CARV|| view using \(self)")
        
        ModelManager.getInstance().setDeletionmanager(deletionManager: deletionManager)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        session.run(config)
        
        self.configureTapGestureRecognizer()
    }
    
    private func initializeSettings() {
        self.updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        self.updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        self.updateLidarDebug(isEnabled: sessionSettings.isLidarDebugEnabled)
    }
    
    private func setupSubscribers() {
        self.peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled)
        }
        self.objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled)
        }
        self.lidarDebugCancellable = sessionSettings.$isLidarDebugEnabled.sink { [weak self] isEnabled in
            self?.updateLidarDebug(isEnabled: isEnabled)
        }
    }
    
    private func updatePeopleOcclusion(isEnabled: Bool) {
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
        if self.environment.sceneUnderstanding.options.contains(.occlusion) {
            self.environment.sceneUnderstanding.options.remove(.occlusion)
        } else {
            self.environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    private func updateLidarDebug(isEnabled: Bool) {
        if self.debugOptions.contains(.showSceneUnderstanding) {
            self.debugOptions.remove(.showSceneUnderstanding)
        } else {
            self.debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    // MARK: Gesture Recognizer
    struct Holder {
        static var anchorMap = [String:AnchorEntity]()
        static var objectMoved: Entity? = nil
        static var zoomEnabled = false
        static var deletionEnabled = false
        static var physicsEnabled = false
    }
    
    func configureTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        //DEBUG
        print("DEBUG:: CARV|| handling tap")
        if (!Holder.deletionEnabled && !Holder.zoomEnabled && sessionSettings.isPhysicsEnabled) {
            ModelManager.getInstance().handlePhysics(recognizer: recognizer, zoomIsEnabled: Holder.zoomEnabled)
        } else if (Holder.deletionEnabled && !Holder.zoomEnabled){
            ModelManager.getInstance().handleDeleteion(recognizer: recognizer)
        }
    }
    
    // MARK: @MainActor
    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
