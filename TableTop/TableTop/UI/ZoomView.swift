//
//  ZoomView.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

class ZoomView: ObservableObject {
    @Published var ZoomEnabled: Bool = false {
        willSet(newValue) {
            print("Setting Zoom Enabled to \(String(describing: newValue.description))")
        }
    }
    
    @Published var changed: Bool = false {
        willSet(newValue) {
        }
    }
    
    func getValue() -> Bool {
        return ZoomEnabled
    }
}
