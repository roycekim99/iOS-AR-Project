import RealityKit
import ARKit
import FocusEntity
import SwiftUI


// UIViewRepresentable converts UIKit view to SwiftUI
// RealityKit view is UIKit view
struct ARSceneContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var deletionManager: DeletionManager
    
    var serverHandler = ServerHandler.getInstance()
    
    static var originPoint = AnchorEntity()
    static var floor = ModelEntity()
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, deletionManager: deletionManager)
        
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
            }
            else {
                //DEBUG
                print("DEBUG:: ARSC|| confirmed model: \(confirmedModel.name)")
                ModelManager.getInstance().place(for : confirmedModel, reqPos: nil)
                ModelManager.getInstance().addActiveModel(modelID: confirmedModel.model_uid, model: confirmedModel)
            }
            self.placementSettings.confirmedModel = nil
            self.placementSettings.originfloor = false
        }
    }
    
    // fun place floor in arview container
    private func placeFloor(in arView: ARView, for setOrigin: Bool) {
        let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [SimpleMaterial()])
        floor.generateCollisionShapes(recursive: true)
        floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        floor.components[ModelComponent.self] = nil
        
        floor.name = "floor"
        
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(floor)
        
        arView.scene.addAnchor(anchorEntity)
        
        // set origion point
        if setOrigin == true {
            ARSceneContainer.originPoint = anchorEntity
            ARSceneContainer.floor = floor
            print("DEBUG:: ARSC|| set origin point")
        }
        
        print("DEBUG:: ARSC|| added floor")
    }
}
