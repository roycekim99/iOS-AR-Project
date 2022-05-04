// downloaded models
// store downloaded models
// load model entity
// store loaded model entities
// clone model entity


import RealityKit
import Combine

enum ModelCategory: CaseIterable {
    case test
    case set
    case board
    case pieces
    case figures
    case unknown
    
    var label: String {
        get {
            switch self {
            case .test:
                return "Test"
            case .set:
                return "Sets"
            case .board:
                return "Boards"
            case .pieces:
                return "Pieces"
            case .figures:
                return "Figures"
            case .unknown:
                return "Unknown"
            }
        }
    }
}


class ModelLibrary {
    
    // Holds an array of model entities
    static var currentAssets: [Model] = []
    
    static var loadedModelEntities = [Int: ModelEntity]()
    
    private var cancellable: AnyCancellable? = nil
    

    func downloadAssest(){
        // call server getAPI
        // get json files and model manager to unpack json files
        // then create model instances
        // add instances to currentAssets
    }
    
    // load model entity and store in loadModelEntities
    func loadModelToClone(for model: Model) {
        
        let fileName = model.name + ".usdz"
        
        cancellable = ModelEntity.loadModelAsync(named: fileName)
            .sink(receiveCompletion:{ loadCompletion in
                
                switch loadCompletion {
                case .failure(let error): print("DEBUG::Unable to load modelEntity for \(fileName). Error \(error.localizedDescription)")
                    self.cancellable?.cancel()
                case .finished:
                    self.cancellable?.cancel()
                    break
                }
            } , receiveValue: { modelEntity in
                
                ModelLibrary.loadedModelEntities[model.assetID] = modelEntity
                ModelLibrary.loadedModelEntities[model.assetID]?.scale *= model.scaleCompensation
                self.cancellable?.cancel()
                print("DEBUG:: model has been loaded")
            })
    }
    
    // clone model entity and return this entity to be placed into the scene
    func getModelEntity(for model: Model) -> ModelEntity {
        
        let clonedEntity: ModelEntity?
        
        if let modelEntity = ModelLibrary.loadedModelEntities[model.assetID] {
            clonedEntity = modelEntity.clone(recursive: true)
        }  else {
            // load model
            loadModelToClone(for: model)
            print("DEBUG::Model was not loaded prior to cloning. Finished loading")
            let modelEntity = ModelLibrary.loadedModelEntities[model.assetID]
            clonedEntity = modelEntity?.clone(recursive: true)
            
        }
        print("DEBUG:: loaded model ID: " + String(model.assetID))
        return clonedEntity!
    }
    
    // return categories for displaying in browseview
    func getCategory(category: ModelCategory) -> [Model] {
        return ModelLibrary.currentAssets.filter( {$0.category == category})
    }
    
    // TODO: only for testing purpose. get rid of it after finishing download function 
    init() {
        
        // Modern Checker Set
        let black1 = Model(name: "Black_1", category: .test, scaleCompensation: 1/1, childs: [], assetID: 0)
        let black2 = Model(name: "Black_2", category: .test, scaleCompensation: 1/1, childs: [], assetID: 1)
        let black3 = Model(name: "Black_3", category: .test, scaleCompensation: 1/1, childs: [], assetID: 2)
        let black4 = Model(name: "Black_4", category: .test, scaleCompensation: 1/1, childs: [], assetID: 3)
        let black5 = Model(name: "Black_5", category: .test, scaleCompensation: 1/1, childs: [], assetID: 4)
        let black6 = Model(name: "Black_6", category: .test, scaleCompensation: 1/1, childs: [], assetID: 5)
        let black7 = Model(name: "Black_7", category: .test, scaleCompensation: 1/1, childs: [], assetID: 6)
        let black8 = Model(name: "Black_8", category: .test, scaleCompensation: 1/1, childs: [], assetID: 7)
        let black9 = Model(name: "Black_9", category: .test, scaleCompensation: 1/1, childs: [], assetID: 8)
        let black10 = Model(name: "Black_10", category: .test, scaleCompensation: 1/1, childs: [], assetID: 9)
        let black11 = Model(name: "Black_11", category: .test, scaleCompensation: 1/1, childs: [], assetID: 10)
        let black12 = Model(name: "Black_12", category: .test, scaleCompensation: 1/1, childs: [], assetID: 11)
        
        let red1 = Model(name: "Red_1", category: .test, scaleCompensation: 1/1, childs: [], assetID: 12)
        let red2 = Model(name: "Red_2", category: .test, scaleCompensation: 1/1, childs: [], assetID: 13)
        let red3 = Model(name: "Red_3", category: .test, scaleCompensation: 1/1, childs: [], assetID: 14)
        let red4 = Model(name: "Red_4", category: .test, scaleCompensation: 1/1, childs: [], assetID: 15)
        let red5 = Model(name: "Red_5", category: .test, scaleCompensation: 1/1, childs: [], assetID: 16)
        let red6 = Model(name: "Red_6", category: .test, scaleCompensation: 1/1, childs: [], assetID: 17)
        let red7 = Model(name: "Red_7", category: .test, scaleCompensation: 1/1, childs: [], assetID: 18)
        let red8 = Model(name: "Red_8", category: .test, scaleCompensation: 1/1, childs: [], assetID: 19)
        let red9 = Model(name: "Red_9", category: .test, scaleCompensation: 1/1, childs: [], assetID: 20)
        let red10 = Model(name: "Red_10", category: .test, scaleCompensation: 1/1, childs: [], assetID: 21)
        let red11 = Model(name: "Red_11", category: .test, scaleCompensation: 1/1, childs: [], assetID: 22)
        let red12 = Model(name: "Red_12", category: .test, scaleCompensation: 1/1, childs: [], assetID: 23)
        
        let floor = Model(name: "floor", category: .test, scaleCompensation: 1/1, childs: [], assetID: 24)
        
        let checkersBoard = Model(name: "Checkers Board", category: .set, scaleCompensation: 1/1, childs: [black1, black2, black3, black4, black5, black6, black7, black8, black9, black10, black11, black12, red1, red2, red3, red4, red5, red6, red7, red8, red9, red10, red11, red12], assetID: 25)
        
        ModelLibrary.currentAssets += [checkersBoard]
        
                       // Sets
                       // Games
        let chess = Model(name: "Chess", category: .board, scaleCompensation: 2/10000, childs: [], assetID: 26)
        let modernCheckers = Model(name: "Modern Checkers", category: .board, scaleCompensation: 1/2, childs: [], assetID: 27)
        let vintageCheckers = Model(name: "Vintage Checkers", category: .board, scaleCompensation: 1/5000, childs: [], assetID: 28)
        
        ModelLibrary.currentAssets += [chess, modernCheckers, vintageCheckers, floor]
        
                       // Pieces
        let blackCheckersPiece = Model(name: "Black_Piece", category: .pieces, scaleCompensation: 1/1, childs: [], assetID: 29)
        let redCheckersPiece = Model(name: "Red_Piece", category: .pieces, scaleCompensation: 1/1, childs: [], assetID: 30)
        
        ModelLibrary.currentAssets += [blackCheckersPiece, redCheckersPiece]
        
                       // Figures
        let dripGoku = Model(name: "Drip Goku", category: .figures, scaleCompensation: 1/1500, childs: [], assetID: 31)
        let goku = Model(name: "Goku", category: .figures, scaleCompensation: 1/500, childs: [], assetID: 32)
        
        ModelLibrary.currentAssets += [dripGoku, goku]
        
    }

}



