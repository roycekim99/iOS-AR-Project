//
//  CustomARView.swift
//  TableTop
//
//  Created by Ashley Li on 4/11/22.
//

// an ARView instance

import RealityKit
import ARKit
import FocusEntity
import SwiftUI

class CustomARView: ARView {
    
    var focusEntity: FocusEntity?
    var deletionManager: DeletionManager
    
    required init(frame frameRect: CGRect, deletionManager: DeletionManager) {
        self.deletionManager = deletionManager
        
        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
        
        configure()
        self.handleObject()
    }
    
    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
    }
    
}
