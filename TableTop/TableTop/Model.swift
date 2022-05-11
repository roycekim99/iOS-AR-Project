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
    var anchorEntity = AnchorEntity()
    var modelEntity = ModelEntity()
    var model_uid: String 
    var scaleCompensation: Float
    var position: SIMD3<Float>
    var thumbnail: UIImage

    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0, childs: [Model]){
        self.name = name
        self.category = category
        self.scaleCompensation = scaleCompensation
        self.childs = childs
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.position = SIMD3<Float>()
        self.model_uid = ""
    }
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0, childs: [Model], assetID: Int) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        self.childs = childs
        self.position = SIMD3<Float>()
        self.model_uid = String(assetID)
        
    }
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0, childs: [Model], assetID: String) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        self.childs = childs
        self.position = SIMD3<Float>()
        self.model_uid = assetID
    }
    
    init(from: Model){
        self.name = from.name
        self.category = from.category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = from.scaleCompensation
        self.childs = from.childs
        self.position = SIMD3<Float>()
        self.model_uid = ""
    }
    
    
    
    func setAnchorEntity(_ inputModel: inout AnchorEntity){
        self.anchorEntity = inputModel
    }
    
    func setModelEntity(_ inputModel: inout ModelEntity){
        self.modelEntity = inputModel
    }
    
    func setModelID(to newID: String){
        self.model_uid = newID
    }
    
    func getModelEntity() -> ModelEntity{
        return self.modelEntity
    }
    
    func getAnchorEntity() -> AnchorEntity{
        return self.anchorEntity
    }
    
    func getModelUID() -> String{
        return self.model_uid
    }
    
    static func getRelativePosition(from model: ModelEntity, to origin: Entity) -> SIMD3<Float> {
        return model.position(relativeTo: origin)
    }
    
    //func updatePosition(pos)
}
