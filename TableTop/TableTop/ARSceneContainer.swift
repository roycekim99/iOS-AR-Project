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
        
        /// Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmedModel {
            if confirmedModel.name == "floor" {
                self.placeFloor(in: arView, for: self.placementSettings.originFloor!)
            }
            else {
                // Debug code
                let originPointPos = ARSceneContainer.originPoint.position
                print("DEBUG:: ARSC|| Confirmed model's name: \(confirmedModel.name)")
                print("DEBUG:: ARSC|| current origin: \(originPointPos)")
                // End debug code
                
                self.cloneAndPlace(modelSelected: confirmedModel)
            }
            self.placementSettings.confirmedModel = nil
            self.placementSettings.originFloor = false
        }
    }
    
    /// Given a Model object, this function gets a cloned copy, places it, adds it to the activeModel's array for bookkeeping,
    /// and emit the data to the server
    private func cloneAndPlace(modelSelected confirmedModel: Model){
        let selectedClonedModel = ModelLibrary().getModelCloned(from: confirmedModel)
        ModelManager.getInstance().place(for : selectedClonedModel, reqPos: nil)
        ModelManager.getInstance().addActiveModel(modelID: selectedClonedModel.model_uid, model: selectedClonedModel)
        ModelManager.getInstance().emitPlacementData(forModel: selectedClonedModel)
    }
    
    /// Placing a floor, which acts as an origin for the scene. Important for
    ///  attempting to simulate relative placement for multiplayer users.
    ///  The "floor" is a box, because there were with issues falling through the
    ///  previous implementation, which was using a plane as a "floor".
    private func placeFloor(in arView: ARView, for setOrigin: Bool) {
        //let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [SimpleMaterial()])
        
        /// Create the box object, initializing it's properties.
        let floor = ModelEntity(mesh: .generateBox(size: [100,50,100]), materials: [SimpleMaterial()])
        floor.generateCollisionShapes(recursive: true)
        floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        floor.components[ModelComponent.self] = nil
        floor.name = "floor"
        /// Box is 50 units tall, so offsetting the y-value sets the top of the box
        /// at surface level of where camera is looking.
        floor.transform.translation.y += -25
        /// Attach the floor entity to an anchor entity, and add it to the scene.
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(floor)
        arView.scene.addAnchor(anchorEntity)
        
        /// Set origin point
        if setOrigin == true {
            ARSceneContainer.originPoint = anchorEntity
            ARSceneContainer.floor = floor
            
            // Debug code
            let originPointPos = ARSceneContainer.originPoint.position
            print("DEBUG:: ARSC|| Origin point pos: \(originPointPos)")
        }
        print("DEBUG:: ARSC|| Floor added successfully!")
    }
    
    /*
    func placeSphere(in arView: ARView, for setOrigin: Bool) {
        let sphere = ModelEntity(mesh: .generateSphere(radius: 1), materials: [SimpleMaterial()])
        sphere.generateCollisionShapes(recursive: true)
        sphere.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        sphere.components[ModelComponent.self] = nil
        sphere.name = "sphere"
        
        let anchorEntity2 = AnchorEntity(plane: .horizontal)
        anchorEntity2.addChild(sphere)
        arView.scene.addAnchor(anchorEntity2)
        
        if setOrigin == true {
            ARSceneContainer.originPoint = anchorEntity2
            ARSceneContainer.floor = sphere
            
            // Debug code
            let originPointPos = ARSceneContainer.originPoint.position
            print("DEBUG:: ARSC|| Origin point pos: \(originPointPos)")
            
        }
        print("DEBUG:: ARSC|| Sphere added successfully!")
    }
    */
}
