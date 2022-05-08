//
//  Model.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import SwiftUI
import RealityKit
import Combine


// TODO: uncomment position after figuring out how to get position
class Model {
    var name: String
    var category: ModelCategory
    var childs: [Model]
    var asset_UID: Int  //TODO: UID
    var scaleCompensation: Float
    var position: SIMD3<Float>
    var thumbnail: UIImage

    
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0, childs: [Model], assetID: Int) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        self.childs = childs
        self.asset_UID = assetID
        self.position = SIMD3<Float>()
    }
    
    //func updatePosition(pos)
    
    
}
