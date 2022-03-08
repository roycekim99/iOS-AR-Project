//
//  ContentView.swift
//  TableTop
//
//  Created by Jet Aung on 1/26/22.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @State private var isControlsVisible: Bool = true
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    @State private var isZoomEnabled: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ARViewContainer()
            
            // If no model is selected for placement, show default UI
            if self.placementSettings.selectedModel == nil {
                ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings, isZoomEnabled: $isZoomEnabled)
            } else {
                // Show placement view
                PlacementView()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @EnvironmentObject var zoom: ZoomView
    @EnvironmentObject var sceneManager: SceneManager
    
    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings, zoom: zoom, sceneManager: sceneManager)
        
        // Add floor so that models do not fall infinitely on the floor
        // Change so that there is a floor every entity
        // Or change so that you scan an area before playing to determine where floor is
        let floor = ModelEntity(mesh: .generateBox(size: [1000, 0, 1000]), materials: [SimpleMaterial()])
        floor.generateCollisionShapes(recursive: true)
        if let collisionComponent = floor.components[CollisionComponent.self] as? CollisionComponent {
            floor.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 0, material: nil, mode: .static)
            floor.components[ModelComponent.self] = nil // make the floor invisible
        }
        
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(floor)
        arView.scene.addAnchor(anchorEntity)
        print("added floor")
        
        sceneManager.floor = anchorEntity
        
        // Subscribe to SceneEvents.Update
        // Check every frame for updates from the scene if object is placed, deleted, moved, etc.
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            
            self.updateScene(for: arView)
            
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
            
            self.place(modelEntity, in: arView)
            // After creating children variable to Model
            for chd in confirmedModel.childs {
                //chd.asyncLoadModelEntity()
                print(chd.name)
                self.place(chd.modelEntity!, in: arView)
            }
            self.placementSettings.confirmedModel = nil
        }
    }
    

    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
        // 1. Clone modelEntity. This creates an identical copy of modelEntty and references the same model. This also allows us to have multple models of the same asset in our scene.
        let clonedEntity = modelEntity.clone(recursive: true)
        
        // 2. Enable gestures.
        clonedEntity.generateCollisionShapes(recursive: true)
        if let collisionComponent = clonedEntity.components[CollisionComponent.self] as? CollisionComponent {
            clonedEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 100, material: nil , mode: .dynamic)
        }
        arView.installGestures(for: clonedEntity).forEach { entityGesture in
            entityGesture.addTarget(arView, action: #selector(CustomARView.transformObject(_:)))
        }
        self.sceneManager.modelEntities.append(clonedEntity)
        // 3. Create an anchorEntity and add clonedEntity to the anchorEntity
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        // 4. Add the achorEntity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        sceneManager.floor.addChild(anchorEntity, preservingWorldTransform: true)
        
        print(anchorEntity.position)
        
        print("Added modelEntity to scene.")
    }
    
    func moveAll( check: inout Bool, modelEntities: [ModelEntity]) {
        for ent in modelEntities {
            if check {
                ent.physicsBody?.mode = .kinematic
                ent.transform.translation.y += 0.01
                
            } else {
                ent.transform.translation.y += -0.01
                ent.physicsBody?.mode = .dynamic
            }
        }
    }
    
}

class SceneManager: ObservableObject {
    @Published var modelEntities: [ModelEntity] = []
    @Published var floor = AnchorEntity()
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
            .environmentObject(ZoomView())
            .environmentObject(SceneManager())
    }
}


