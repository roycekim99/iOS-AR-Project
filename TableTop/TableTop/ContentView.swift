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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ARViewContainer()
            
            // If no model is selected for placement, show default UI
            if self.placementSettings.selectedModel == nil {
                ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings)
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
    
    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
        
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
        
        // Subscribe to SceneEvents.Update
        // Check every frame for updates from the scene if object is placed, deleted, moved, etc.
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            
            self.updateScene(for: arView)
            
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        
        // Only display focusEntity when the user has selected a model for plaement
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
            clonedEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 1, material: nil, mode: .dynamic)
        }
        // Enable gestures for children of objects
        for ch in clonedEntity.children {
            ch.generateCollisionShapes(recursive: true)
            if let collisionComponent = ch.components[CollisionComponent.self] as? CollisionComponent {
                clonedEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 1, material: nil, mode: .kinematic)
            }
            arView.installGestures(for: ch as! HasCollision)
        }
        arView.installGestures(for: clonedEntity)
        
        // 3. Create an anchorEntity and add clonedEntity to the anchorEntity
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        // 4. Add the achorEntity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        print("Added modelEntity to scene.")
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
    }
}
