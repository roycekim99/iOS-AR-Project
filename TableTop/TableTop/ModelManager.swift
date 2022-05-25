import RealityKit
import ARKit
import SwiftUI

class ModelManager{
    private static var MMInstance = ModelManager()
    
    var objectMoved: Entity? = nil
    var zoomEnabled = false
    var deletionEnabled = false
    
    /// [UID: Model]
    var activeModels = [String: Model]()
    var floorModel: ModelEntity? = nil
    
    /// Temp way to initialize an AnchorEntity(wanted to set to nil but can't)
    /// Actual floor will be set when user is forced to set their floor, which is their origin
    var floorAnchor: AnchorEntity = AnchorEntity(.face)
    var targetARView: ARView
    var deletionManager: DeletionManager
    
    private init(target: ARView, deletionManager: DeletionManager){
        self.targetARView = target
        self.deletionManager = deletionManager
        
        // Debug code
        print("DEBUG:: ModelManager properly set up")
    }
    
    // Generic instantiation
    private init(){
        self.targetARView = ARView()
        self.deletionManager = DeletionManager()
        
        // Debug code
        print("DEBUG:: ModelManager lazily setup...")
    }
    
    static func getInstance() -> ModelManager{
        return MMInstance
    }
    
    func loadIfNotLoaded(model: Model){
        if ModelLibrary.loadedModels[model.getModelUID()] == nil{
            ModelLibrary().loadModelToClone(for: model)
            
            for childModel in model.childs {
                if ModelLibrary.loadedModels[childModel.getModelUID()] == nil {
                    ModelLibrary().loadModelToClone(for: childModel)
                }
            }
        }
    }
    
    func clearActiveModels() {
        print("DEBUG:: MM|| activeModels before clearing \(activeModels)")
        activeModels = [String: Model]()
        print("DEBUG:: MM|| Reset activeModels \(activeModels)")
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
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity
        {
            switchPhysicsMode(for: selectedModel, zoomIsEnabled: zoomIsEnabled)
            //TODO: setup tap function?
        }
    }
    
    func handleDeleteion(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity
        {
            if selectedModel.name == "floor" { return }
            
            self.deletionManager.entitySelectedForDeletion = selectedModel
            //TODO: handle delete
        }
    }
    
    @objc func handleTranslation(_ sender: UIGestureRecognizer) {
        // TODO: - Can someone explain this
        guard let gesture = sender as? EntityTranslationGestureRecognizer else { return }
        
        let targetModelEntity = gesture.entity as? ModelEntity
    
        if self.objectMoved == nil {
            self.objectMoved = targetModelEntity
        } else if (targetModelEntity != self.objectMoved) {
            return
        }
            
        let model = getModelWithMEntity(modEnt: targetModelEntity!)
        
        switch gesture.state {
        case .began:
            print("DEBUG::MM|| Translation started")
            model.transformationStartPos = targetModelEntity!.position
            
            print("DEBUG:: MM|| startPos: \(model.transformationStartPos)")
            
        // TODO: Can someone explain the logic and why of this code
            if (CustomARView.Holder.zoomEnabled) {
                print("DEBUG:: MM|| Zoom enabled")
                for (_,modelObj) in self.activeModels {
                    // Save current child parent relationship
                    CustomARView.Holder.anchorMap[modelObj.getModelUID()] = modelObj.getModelEntity().parent as? AnchorEntity
                    
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(targetModelEntity, preservingWorldTransform: true)
                    }
                }
                // TODO: Why are we setting the parent of the floor?
                ARSceneContainer.floor.setParent(targetModelEntity, preservingWorldTransform: true)
            }
        case .ended:
            print("DEBUG:: MM|| Translation ended")

            let finalPos = targetModelEntity!.position
            print("DEBUG:: MM|| finalPos: \(finalPos)")
            
            var deltaPos = SIMD3<Float>()
            deltaPos.x = finalPos.x - model.transformationStartPos.x
            deltaPos.y = finalPos.y - model.transformationStartPos.y
            deltaPos.z = finalPos.z - model.transformationStartPos.z
            
            print("DEBUG:: MM|| deltaPOS: \(deltaPos)")
            
            let emissionData = SharedSessionData(
                modelUID: model.model_uid,
                modelName: model.name,
                positionX: deltaPos.x,
                positionY: deltaPos.y,
                positionZ: deltaPos.z)

            ServerHandler.getInstance().emitModelTransformed(data: emissionData)

            // TODO: Someone explain purpose and reasoning of code below
            if (CustomARView.Holder.zoomEnabled) {
                for (_,modelObj) in self.activeModels {
                    let modelEntity = modelObj.getModelEntity()
                    if (modelEntity != targetModelEntity!) {
                        modelEntity.setParent(CustomARView.Holder.anchorMap[modelObj.getModelUID()], preservingWorldTransform: true)
                    }
                }
                CustomARView.Holder.anchorMap.removeAll()
                //print("Origin point old position: \(ARSceneContainer.originPoint.position)")
                ARSceneContainer.originPoint.setPosition([0,0,0], relativeTo: ARSceneContainer.floor)
                ARSceneContainer.floor.setParent(ARSceneContainer.originPoint, preservingWorldTransform: true)
                //print("Origin point new position: \(ARSceneContainer.originPoint.position)")
                //print("Floor position: \(ARSceneContainer.floor.position)")
            }
            self.objectMoved = nil
            model.transformationStartPos = finalPos
        default:
            return
        }
    }
    
    /// There are two ways that this place function is called:
    ///     - A player places a model somewhere in the scene: when this happens, the parameter reqPos is nil and we will not set it's position
    ///     - A player receives a model-placed event from the server, with a relative position, which is then used to set the position of the object
    func place(for model: Model, reqPos posRequested: SIMD3<Float>?) {
        targetARView.installGestures(.all, for: model.getModelEntity()).forEach { entityGesture in
            entityGesture.addTarget(ModelManager.getInstance(), action: #selector(ModelManager.getInstance().handleTranslation(_ :)))
        }
        
        var anchorEntity = AnchorEntity(plane: .any)
        
        if (posRequested != nil) {
            anchorEntity.setPosition(posRequested!, relativeTo: ARSceneContainer.originPoint)
//            print("DEBUG::NH MM|| received relative position:", posRequested)
//            print("DEBUG::NH MM|| origin point position:     ", ARSceneContainer.originPoint)
//            print("DEBUG::NH MM|| anchorEntity's position:   ", anchorEntity.position)
//            print("DEBUG::NH MM|| current relative position: ", Model.getRelativePosition(for: anchorEntity))
        }
        
        anchorEntity.addChild(model.getModelEntity())
        model.setAnchorEntity(&anchorEntity)
        
        targetARView.scene.addAnchor(anchorEntity)

        print("DEBUG:: MM || Cloned model: \(model.name)")

        for (index,child) in model.childs.enumerated() {
            //print("DEBUG:: going thorugh children for \(selectedClonedModel.name)..." + child.name)
            let clonedChildModel = ModelLibrary().getModelCloned(from: child)
            self.place(for: clonedChildModel, reqPos: posRequested)
            clonedChildModel.setModelID(to: model.model_uid + "_" + String(index))
            self.addActiveModel(modelID: clonedChildModel.model_uid, model: clonedChildModel)
        }
                
        print("DEBUG:: MM ||| place ending! active models: \(ModelManager.getInstance().activeModels.count)")
//        for modelInstance in ModelManager.getInstance().activeModels {
//            print("DEBUG:: MM ||| place ENDED! active model name: \(modelInstance.value.name)")
//        }
    }
    
    /// This function here is only called when we received data from the server.
    /// ServerHandler will call this function when receiving a "model-transformed" message.
    /// This function then receives the new relative position and set the active model's
    /// position to the new relative position.
    func moveModel(model selectedModel: Model, by deltaPos: SIMD3<Float>){
        let currentPos = selectedModel.getModelEntity().position
        var changedPos = currentPos
        changedPos.x += deltaPos.x
        changedPos.y += deltaPos.y
        changedPos.z += deltaPos.z
        
        print("DEBUG:: MM|| moveModel currentPos: \(currentPos)")
        print("DEBUG:: MM|| moveModel changedPos: \(changedPos)")
        
        // TODO: Things we can try?
        // - setPosition on anchor
        // - try relativeTo: origin
        // - try using ONLY relative to the world space, aka relativeTo: nil
        
        // Also, data received is a delta position of the target object,
        // so it would make sense to setPosition relative to the model's old position
        let currModel = selectedModel.getModelEntity()
        // Maybe we need to make an temporary exact copy of the entity, setPosition
        // relative to that copy, and then delete the copy?
        // So far with this implentation below, translation works a little initially,
        // but eventually no matter what direction you move the object, the receiver's
        // object keeps moving the same direction. lol.
        currModel.setPosition(changedPos, relativeTo: currModel)
    }
    
    /// Given a Model object, obtain it's relative position from the origin point, created a SharedSessionData object to send to the server
    func emitPlacementData(forModel clonedModelInput: Model){
        let relativePos = Model.getRelativePosition(for: clonedModelInput.getAnchorEntity())
        
        let dataToEmit = SharedSessionData(
            modelUID: clonedModelInput.model_uid,
            modelName: clonedModelInput.name,
            positionX: relativePos.x,
            positionY: relativePos.y,
            positionZ: relativePos.z)

        ServerHandler.getInstance().emitModelPlaced(data: dataToEmit)
    }
    
    func moveAll(check: Bool){
        if (CustomARView.Holder.physicsEnabled) {
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
    }
    
    func resetAll(){
        for (_, modelObj) in activeModels {
            let tempModel = modelObj.getModelEntity()
            if (CustomARView.Holder.physicsEnabled) {
                tempModel.physicsBody?.mode = .dynamic
            } else {
                tempModel.physicsBody?.mode = .kinematic
            }
        }
    }
    
    
    // MARK: Private functions
    private func switchPhysicsMode(for selectedModel: ModelEntity, zoomIsEnabled: Bool) {
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
    
    private func getModelWithMEntity(modEnt: ModelEntity) -> Model {
        var model: AnyObject?
        
        print("DEBUG:: MM.getEntity, entity ID: \(modEnt.id )")

        for mod in ModelManager.getInstance().activeModels {
            if (mod.value.modelEntity == modEnt) {
                print("DEBUG:: MM.getEntity, ENTITY FOUND: \(mod.value.name)")

                model = mod.value
            }
        }
        return model as! Model
    }
       
    private func getModelFromActive(reqModelEnt: Entity) -> Model?{
        for (_, modelObj) in ModelManager.getInstance().activeModels {
            if( modelObj.getModelEntity() == reqModelEnt){
                return modelObj
            }
        }
        return nil
    }
}

