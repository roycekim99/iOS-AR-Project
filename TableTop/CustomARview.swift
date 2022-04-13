//
//  CustomARview.swift
//  TableTop
//
//  Created by Ashley Li on 4/12/22.


import RealityKit
import ARKit
import FocusEntity
import SwiftUI

// an ARview instance
class CustomARView: ARView {

    var focusEntity: FocusEntity?

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        focusEntity = FocusEntity(on: self, focus: .classic)

        configure()
    }

    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
    }

}
