// This class controls all the active models in the scene.
// ModelManager is a singleton.

import RealityKit
import ARKit
import SwiftUI

class ModelManager{
    private static var MMInstance = ModelManager()
    
    var objectMoved: Entity? = nil
    var zoomEnabled = false
    var deletionEnabled = false
    
    // [UID:Model]
    var activeModels = [String: Model]()
    var floorModel: ModelEntity? = nil
    
    // Temp way to initialize an AnchorEntity(wanted to set to nil but can't)
    // Actual floor will be set when user is forced to set their floor, which is their origin
    var floorAnchor: AnchorEntity = AnchorEntity(.face)
    
    var targetARView: ARView
    var deletionManager: DeletionManager
    
    private init(target: ARView, deletionManager: DeletionManager){
        self.targetARView = target
        self.deletionManager = deletionManager
        
        //DEBUG
        print("DEBUG:: ModelManager properly set up!!!")
    }
    
    //generic instantiation
    private init(){
        self.targetARView = ARView()
        self.deletionManager = DeletionManager()
        
        //DEBUG
        print("DEBUG:: ModelManager lazily setup...")
    }
    
    static func getInstance() -> ModelManager{
        return MMInstance
    }
    
    func clearActiveModels() {
        print("DEBUG:: activeModels before clearing \(activeModels)")
        activeModels = [String: Model]()
        print("DEBUG:: reset activeModels \(activeModels)")
    }
    
    func setARView(targetView: ARView){
        self.targetARView = targetView
    }
    
    func setDeletionmanager(deletionManager: DeletionManager){
        self.deletionManager = deletionManager
    }
    
    func addActiveModel(modelID: String, model: Model){
        self.activeModels[modelID] = model
    }
    
    func addFloorModel(floor: ModelEntity) {
        self.floorModel = floor
    }
    
    func addFloorAnchor(anchor: AnchorEntity) {
        self.floorAnchor = anchor
    }
    
    func handlePhysics(recognizer:UITapGestureRecognizer, zoomIsEnabled: Bool) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity {
            print()
            
            switchPhysicsMode(for: selectedModel, zoomIsEnabled: zoomIsEnabled)
            //TODO: setup tap function
        }
    }
    
    func handleDeleteion(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity {
            self.deletionManager.entitySelectedForDeletion = selectedModel
            
            //TODO: handle delete
        }
    }
    
    @objc func handleTranslation(_ sender: UIGestureRecognizer) {
        //DEBUG
        //print("DEBUG:: MMT|| STARTED TRANSLATION!!")
        guard let gesture = sender as? EntityTranslationGestureRecognizer else { return }
        
        let targetModelEntity = gesture.entity as? ModelEntity
        
    
        if self.objectMoved == nil {
            self.objectMoved = targetModelEntity
        } else if (targetModelEntity != self.objectMoved) {
            return
        }
            
        switch gesture.state {
        case .began:
            
            print("DEBUG::Started Moving")
                
            if (CustomARView.Holder.zoomEnabled) {
                print("DEBUG:: zoooom")
                for (_,modelObj) in self.activeModels {
                    //save current child parent relationship
                    CustomARView.Holder.anchorMap[modelObj.getModelUID()] = modelObj.getModelEntity().parent as? AnchorEntity
                    
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(targetModelEntity, preservingWorldTransform: true)
                    }
                }
            }
        case .ended:
            print("DEBUG::Stopped Moving")
                
            let model = getModelType(modEnt: targetModelEntity!)
        
            let finalRelativePos = Model.getRelativePosition(from: targetModelEntity!, to: ARSceneContainer.originPoint)
           
            print(model.name)
            print(finalRelativePos)
            
            //EMIT
            let emissionData = SharedSessionData(
                modelUID: model.model_uid,
                modelName: model.name,
                positionX: finalRelativePos.x,
                positionY: finalRelativePos.y,
                positionZ: finalRelativePos.z)
            
            ServerHandler.getInstance().emitModelTransformed(data: emissionData)


            
            if (CustomARView.Holder.zoomEnabled) {
                for (_,modelObj) in self.activeModels {
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(CustomARView.Holder.anchorMap[modelObj.getModelUID()], preservingWorldTransform: true)
                    }
                }
            }
            //self.anchorMap.removeAll()
            
            
        default:
            return
        }
        
    }
    
    
    func place(for model: Model, reqPos posRequested: SIMD3<Float>?) {
        //DEBUG
        print("DEBUG:: place started for \(model.name)! active models: \(ModelManager.getInstance().activeModels.count)")
        print("DEBUG:: ARSC|| Model cloned from library of size: \(ModelLibrary.availableAssets.count)")
        
        let selectedClonedModel = ModelLibrary().getModelCloned(from: model)
        
        targetARView.installGestures(.all, for: selectedClonedModel.getModelEntity()).forEach { entityGesture in
            entityGesture.addTarget(ModelManager.getInstance(), action: #selector(ModelManager.getInstance().handleTranslation(_ :)))
        }
        
        var anchorEntity: AnchorEntity
        if (posRequested == nil){
            // anchor based on focus entity
            anchorEntity = AnchorEntity(plane: .any)
//            let relativePosTest = Model.worldTransform.translation
            let relativePos = Model.getRelativePosition(from: selectedClonedModel.getModelEntity(), to: ARSceneContainer.originPoint)
            
            let dataToEmit = SharedSessionData(
                modelUID: selectedClonedModel.model_uid,
                modelName: selectedClonedModel.name,
                positionX: relativePos.x,
                positionY: relativePos.y,
                positionZ: relativePos.z)

            ServerHandler.getInstance().emitModelPlaced(data: dataToEmit)
            
        }   else {
            anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.setPosition(posRequested!, relativeTo: ARSceneContainer.originPoint)
        }
        
        
        
        anchorEntity.addChild(selectedClonedModel.getModelEntity())
        selectedClonedModel.setAnchorEntity(&anchorEntity)
        
        targetARView.scene.addAnchor(anchorEntity)

        print("DEBUG:: MM || Cloned model: \(selectedClonedModel.name)")

        for child in selectedClonedModel.childs {
            //print("DEBUG:: going thorugh children for \(selectedClonedModel.name)..." + child.name)
            self.place(for: child, reqPos: posRequested)
        }
        //testing is getrelativepostiion works
//        ModelLibrary().getRelativePosition(from: modelEntity, to: ARSceneManager.originPoint[0])
        
        ModelManager.getInstance().addActiveModel(modelID: selectedClonedModel.getModelUID(), model: selectedClonedModel)
        
        //DEBUG
        print("DEBUG:: MM ||| place ending! active models: \(ModelManager.getInstance().activeModels.count)")
        for modelInstance in ModelManager.getInstance().activeModels {
            print("DEBUG:: MM ||| place ENDED! active model name: \(modelInstance.value.name)")
        }
    }
    
    func moveAll(check: Bool){
        for (_, modelObj) in activeModels {
            let tempModel = modelObj.getModelEntity()
            
            if check {
                tempModel.physicsBody?.mode = .kinematic
                tempModel.transform.translation.y += 0.01
            } else {
                tempModel.transform.translation.y += -0.01
                tempModel.physicsBody?.mode = .dynamic
            }
        }
    }
    
    func resetAll(){
        for (_, modelObj) in activeModels {
            let tempModel = modelObj.getModelEntity()
            tempModel.physicsBody?.mode = .dynamic
        }
    }
    
    // MARK: *private functions*
    private func switchPhysicsMode(for selectedModel: ModelEntity, zoomIsEnabled: Bool){
        
        if (!zoomIsEnabled) {
            if selectedModel.physicsBody.self?.mode == .dynamic {
                print("to kinematic")
                selectedModel.physicsBody.self?.mode = .kinematic
                selectedModel.transform.translation.y += 0.01
            } else if selectedModel.physicsBody.self?.mode == .kinematic {
                print("to dynamic")
                selectedModel.physicsBody.self?.mode = .dynamic
            }
        }
        
    }
    
    private func getModelType(modEnt: ModelEntity) -> Model {
        var model: AnyObject?
        for mod in ModelManager.getInstance().activeModels {
            if (mod.value.modelEntity == modEnt) {
                model = mod.value
            }
        }
        return model as! Model
    }
       
    private func getModelFromActive(reqModelEnt: Entity) -> Model?{
        //1. look through active
            // make sure
        
        for (_, modelObj) in ModelManager.getInstance().activeModels {
            if( modelObj.getModelEntity() == reqModelEnt){
                return modelObj
            }
        }
        
        return nil
        
    }
}

