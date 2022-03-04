//
//  ZoomView.swift
//  TableTop
//
//  Created by Jet Aung on 3/1/22.
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
            //print("coolio")
        }
    }
    
    func getValue() -> Bool {
        return ZoomEnabled
    }
}

