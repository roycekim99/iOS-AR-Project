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
//            print("DEBUG:: Model.getRelativePos:>>")
//            print(Model.getRelativePosition(from: selectedModel))
            switchPhysicsMode(for: selectedModel, zoomIsEnabled: zoomIsEnabled)
            //TODO: setup tap function
        }
    }
    
    func handleDeleteion(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.targetARView)
        
        if let selectedModel = self.targetARView.entity(at: location) as? ModelEntity {
            
            if selectedModel.name == "floor" {
                return
            }
            
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
                ARSceneContainer.floor.setParent(targetModelEntity, preservingWorldTransform: true)
            }
        case .ended:
            print("DEBUG::Stopped Moving")
            // TODO: Unused variable, can we remove?
//            let model = getModelType(modEnt: targetModelEntity!)

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
        
        if (posRequested != nil){
            anchorEntity.setPosition(posRequested!, relativeTo: ARSceneContainer.originPoint)
            print("DEBUG::NH posRequested = ", posRequested!)
        }
        
        anchorEntity.addChild(model.getModelEntity())
        model.setAnchorEntity(&anchorEntity)
        
        targetARView.scene.addAnchor(anchorEntity)

        print("DEBUG:: MM || Cloned model: \(model.name)")

        for child in model.childs {
            //print("DEBUG:: going thorugh children for \(selectedClonedModel.name)..." + child.name)
            let clonedChildModel = ModelLibrary().getModelCloned(from: child)
            self.place(for: clonedChildModel, reqPos: posRequested)
            self.addActiveModel(modelID: clonedChildModel.model_uid, model: clonedChildModel)
        }
                
        print("DEBUG:: MM ||| place ending! active models: \(ModelManager.getInstance().activeModels.count)")
//        for modelInstance in ModelManager.getInstance().activeModels {
//            print("DEBUG:: MM ||| place ENDED! active model name: \(modelInstance.value.name)")
//        }
    }
    
    func moveModel(model selectedModel: Model, to finalPos: SIMD3<Float>){
        //DEBUG
        selectedModel.getModelEntity().setPosition(finalPos, relativeTo: ARSceneContainer.originPoint)
    }
    
    /// Given a Model object, obtain it's relative position from the origin point, created a SharedSessionData object to send to the server
    func emitPlacementData(forModel clonedModelInput: Model){
        let relativePos = Model.getRelativePosition(from: clonedModelInput.getAnchorEntity())
        print("DEBUG:: MM|| Current pos = \(clonedModelInput.getAnchorEntity().position)")
        print("DEBUG:: MM|| NH relativePos = ", relativePos)
        
        let dataToEmit = SharedSessionData(
            modelUID: clonedModelInput.model_uid,
            modelName: clonedModelInput.name,
            positionX: relativePos.x,
            positionY: relativePos.y,
            positionZ: relativePos.z)

        ServerHandler.getInstance().emitModelPlaced(data: dataToEmit)
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
        for (_, modelObj) in ModelManager.getInstance().activeModels {
            if( modelObj.getModelEntity() == reqModelEnt){
                return modelObj
            }
        }
        return nil
    }
}

