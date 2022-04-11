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
    var thumbnail: UIImage
    var childs: [Model]
    var scaleCompensation: Float
    var assetID: Int
//    var position: Float
    
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0, childs: [Model], assetID: Int) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        self.childs = childs
        self.assetID = assetID
//        self.position = position
    }
}
