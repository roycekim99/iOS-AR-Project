import SwiftUI
import RealityKit
import Combine

class PlacementSettings: ObservableObject {
    /// This property retains the cancellable object for our SceneEvents.
    var sceneObserver: Cancellable?
    /// This property retains a record of placed models in the scene.
    /// The last element in the array is the most recently placed model.
    @Published var recentlyPlaced: [Model] = []
    @Published var recentlyPlacedID: [String] = []
    
    init() {
        reset()
    }
    
    func reset() {
        self.selectedModel = Model(
            name: "floor",
            category: .floor,
            scaleCompensation: 1/1,
            childs: [],
            assetID: 100)
        self.originFloor = true
    }
    
    @Published var originFloor: Bool? {
        willSet(newValue){
            print("DEBUG:: Setting origin point")
        }
    }
    
    /// When the user selects a model in BrowseView, this property is set.
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("DEBUG:: Setting selectedModel to \(String(describing: newValue?.name))")
        }
    }
    
    @Published var selectedModelID: String? {
        willSet(newValue) {
            print("DEBUG:: Setting selectedModelID to \(String(describing: newValue))")
        }
    }
    
    // When the user taps confirm in PlacementView, the value of selectedModel is assigned to confirmedModel
    @Published var confirmedModel: Model? {
        willSet(newValue) {
            guard let model = newValue else {
                print("DEBUG:: Clearing confirmedModel")
                return
            }
            
            print("DEBUG:: Setting confirmedModel to \(model.name)")
            
            self.recentlyPlaced.append(model)
        }
    }
    
    // Get ID of the object and use it to pull the asset later on
    @Published var confirmedModelID: String? {
        willSet(newValue) {
            guard let id = newValue else {
                print("DEBUG:: confirmedModel has no ID")
                return
            }
            
            self.recentlyPlacedID.append(id)
        }
    }
}
