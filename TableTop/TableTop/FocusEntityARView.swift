//
//  CustomARView.swift
//  TableTop
//
//  Created by Ashley Li on 4/11/22.
//

// an ARView instance which handles instantiation of a new ARView with a FocusEntity

import RealityKit
import ARKit
import FocusEntity
import SwiftUI

class FocusEntityARView: ARView {
    var activeModelManager = ModelManagerTester()
    
    // MARK: FocusEntity -Start-
    var focusEntity: FocusEntity?
    var deletionManager: DeletionManager
    
    required init(frame frameRect: CGRect, deletionManager: DeletionManager) {
        
        self.deletionManager = deletionManager
        super.init(frame: frameRect)
        
        configure()
    }
    
    private func configure() {
        focusEntity = FocusEntity(on: self, focus: .classic)
        activeModelManager = ModelManagerTester(target: self, deletionManager: self.deletionManager)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        
        self.configureTapGestureRecognizer()
    }

    
    // MARK: Gesture Recognizer
    struct Holder {
        static var anchorMap = [ModelEntity:AnchorEntity]()
        static var objectMoved: Entity? = nil
        static var zoomEnabled = false
        static var deletionEnabled = false
    }
    
    func configureTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        if (!Holder.deletionEnabled && !Holder.zoomEnabled) {
            handlePhysics(recognizer: recognizer)
        } else {
            handleDeletion(recognizer: recognizer)
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