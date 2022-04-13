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
    }
    
    func handleObject() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) as? ModelEntity {
            if entity.physicsBody.self?.mode == .dynamic {
                print("to kinematic")
                entity.physicsBody.self?.mode = .kinematic
                entity.transform.translation.y += 0.01
            } else {
                print("to dynamic")
                entity.physicsBody.self?.mode = .dynamic
            }
        }
    }
    
    @objc func handleTranslation(sender: EntityTranslationGestureRecognizer) {
        
        
        
        switch sender.state {
        case .began:
            print("Started Moving")
        case .ended:
            print("Stopped Moving")
        default:
            return
        }
    }
}
