import RealityKit
import ARKit
import FocusEntity
import SwiftUI


// UIViewRepresentable converts UIKit view to SwiftUI
// RealityKit view is UIKit view
struct ARSceneContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var deletionManager: DeletionManager
    @EnvironmentObject var sessionSettings: SessionSettings

    // connect to the server
//    var serverHandler = ServerHandler.getInstance()
    
    static var originPoint = AnchorEntity()
    static var floor = ModelEntity()
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, deletionManager: deletionManager, sessionSettings: sessionSettings)
        
        // Subscribe to sceneEvents.update
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, {(event) in
            updateScene(for: arView)
        })
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmedModel {
            
            if confirmedModel.name == "floor" {
                self.placeFloor(in: arView, for: self.placementSettings.originfloor!)
            } else {
                print("DEBUG:: ARSC|| confirmed model: \(confirmedModel.name)")
                print("DEBUG:: ARSC|| current origin: \(ARSceneContainer.originPoint.position)")
                
                self.cloneAndPlace(modelSelected: confirmedModel)
            }
            self.placementSettings.confirmedModel = nil
            self.placementSettings.originfloor = false
        }
    }
    
    private func cloneAndPlace(modelSelected confirmedModel: Model){
        let selectedClonedModel = ModelLibrary().getModelCloned(from: confirmedModel)
        
        ModelManager.getInstance().place(for : selectedClonedModel, reqPos: nil)
        ModelManager.getInstance().addActiveModel(modelID: selectedClonedModel.model_uid, model: selectedClonedModel)
        ModelManager.getInstance().emitPlacementData(forModel: selectedClonedModel)
    }
    
    // fun place floor in arview container
    private func placeFloor(in arView: ARView, for setOrigin: Bool) {
        //let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [SimpleMaterial()])
        let floor = ModelEntity(mesh: .generateBox(size: [100,50,100]), materials: [SimpleMaterial()])
        floor.generateCollisionShapes(recursive: true)
        floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        floor.components[ModelComponent.self] = nil
        
        floor.name = "floor"
        
        floor.transform.translation.y += -25
        
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(floor)
        
        arView.scene.addAnchor(anchorEntity)
        
        // set origion point
        if setOrigin == true {
            ARSceneContainer.originPoint = anchorEntity
            ARSceneContainer.floor = floor
            print("DEBUG:: ARSC|| set origin point: \(ARSceneContainer.originPoint.position)")
        }
        print("DEBUG:: ARSC|| added floor")
    }
}
