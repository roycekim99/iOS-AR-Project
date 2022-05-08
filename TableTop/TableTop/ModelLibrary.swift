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
    case pieces
    case board
    case figures
    case unknown
    
    var label: String {
        get {
            switch self {
            case .test:
                return "Floor"
            case .set:
                return "Game Sets"
            case .pieces:
                return "Pieces"
            case .board:
                return "Set Models"
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
    
    // ModelEntity.setPosition(relativeTo: ) may also be useful
    static func getRelativePosition(from model: ModelEntity, to origin: Entity) -> SIMD3<Float> {
//        print("relative position \(model.position(relativeTo: origin))")
        return model.position(relativeTo: origin)
    }
    
    
    
    // TODO: fix this bug here -- taking too long to load
    
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
                
                ModelLibrary.loadedModelEntities[model.asset_UID] = modelEntity
                ModelLibrary.loadedModelEntities[model.asset_UID]?.scale *= model.scaleCompensation
                self.cancellable?.cancel()
                print("DEBUG:: model has been loaded")
            })
    }
    
    // clone model entity and return this entity to be placed into the scene
    func getModelEntity(for model: Model) -> ModelEntity {
        
        let clonedEntity: ModelEntity?
        
        if let modelEntity = ModelLibrary.loadedModelEntities[model.asset_UID] {
            clonedEntity = modelEntity.clone(recursive: true)
        }  else {
            // load model
            loadModelToClone(for: model)
            print("DEBUG::Model was not loaded prior to cloning. Finished loading")
            let modelEntity = ModelLibrary.loadedModelEntities[model.asset_UID]
            clonedEntity = modelEntity?.clone(recursive: true)
            
        }
        print("DEBUG:: loaded model ID: " + String(model.asset_UID))
        return clonedEntity!
    }
    
    // return categories for displaying in browseview
    func getCategory(category: ModelCategory) -> [Model] {
        return ModelLibrary.currentAssets.filter( {$0.category == category})
    }
    
    // TODO: only for testing purpose. get rid of it after finishing download function 
    init() {
                        // Game Sets
        // Modern Checker Set
        let black1 = Model(name: "Black_1", category: .set, scaleCompensation: 1/1, childs: [], assetID: 0)
        let black2 = Model(name: "Black_2", category: .set, scaleCompensation: 1/1, childs: [], assetID: 1)
        let black3 = Model(name: "Black_3", category: .set, scaleCompensation: 1/1, childs: [], assetID: 2)
        let black4 = Model(name: "Black_4", category: .set, scaleCompensation: 1/1, childs: [], assetID: 3)
        let black5 = Model(name: "Black_5", category: .set, scaleCompensation: 1/1, childs: [], assetID: 4)
        let black6 = Model(name: "Black_6", category: .set, scaleCompensation: 1/1, childs: [], assetID: 5)
        let black7 = Model(name: "Black_7", category: .set, scaleCompensation: 1/1, childs: [], assetID: 6)
        let black8 = Model(name: "Black_8", category: .set, scaleCompensation: 1/1, childs: [], assetID: 7)
        let black9 = Model(name: "Black_9", category: .set, scaleCompensation: 1/1, childs: [], assetID: 8)
        let black10 = Model(name: "Black_10", category: .set, scaleCompensation: 1/1, childs: [], assetID: 9)
        let black11 = Model(name: "Black_11", category: .set, scaleCompensation: 1/1, childs: [], assetID: 10)
        let black12 = Model(name: "Black_12", category: .set, scaleCompensation: 1/1, childs: [], assetID: 11)
        
        let red1 = Model(name: "Red_1", category: .set, scaleCompensation: 1/1, childs: [], assetID: 12)
        let red2 = Model(name: "Red_2", category: .set, scaleCompensation: 1/1, childs: [], assetID: 13)
        let red3 = Model(name: "Red_3", category: .set, scaleCompensation: 1/1, childs: [], assetID: 14)
        let red4 = Model(name: "Red_4", category: .set, scaleCompensation: 1/1, childs: [], assetID: 15)
        let red5 = Model(name: "Red_5", category: .set, scaleCompensation: 1/1, childs: [], assetID: 16)
        let red6 = Model(name: "Red_6", category: .set, scaleCompensation: 1/1, childs: [], assetID: 17)
        let red7 = Model(name: "Red_7", category: .set, scaleCompensation: 1/1, childs: [], assetID: 18)
        let red8 = Model(name: "Red_8", category: .set, scaleCompensation: 1/1, childs: [], assetID: 19)
        let red9 = Model(name: "Red_9", category: .set, scaleCompensation: 1/1, childs: [], assetID: 20)
        let red10 = Model(name: "Red_10", category: .set, scaleCompensation: 1/1, childs: [], assetID: 21)
        let red11 = Model(name: "Red_11", category: .set, scaleCompensation: 1/1, childs: [], assetID: 22)
        let red12 = Model(name: "Red_12", category: .set, scaleCompensation: 1/1, childs: [], assetID: 23)
        
        let floor = Model(name: "floor", category: .test, scaleCompensation: 1/1, childs: [], assetID: 24)
        
        let checkersBoard = Model(name: "Checkers Board", category: .set, scaleCompensation: 1/1, childs: [black1, black2, black3, black4, black5, black6, black7, black8, black9, black10, black11, black12, red1, red2, red3, red4, red5, red6, red7, red8, red9, red10, red11, red12], assetID: 25)
        
        // Chess Set
        let bBishop1 = Model(name: "B_Bishop_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 26)
        let bBishop2 = Model(name: "B_Bishop_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 27)
        let bKing = Model(name: "B_King", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 28)
        let bKnight1 = Model(name: "B_Knight_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 29)
        let bKnight2 = Model(name: "B_Knight_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 30)
        let bPawn1 = Model(name: "B_Pawn_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 31)
        let bPawn2 = Model(name: "B_Pawn_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 32)
        let bPawn3 = Model(name: "B_Pawn_3", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 33)
        let bPawn4 = Model(name: "B_Pawn_4", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 34)
        let bPawn5 = Model(name: "B_Pawn_5", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 35)
        let bPawn6 = Model(name: "B_Pawn_6", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 36)
        let bPawn7 = Model(name: "B_Pawn_7", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 37)
        let bPawn8 = Model(name: "B_Pawn_8", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 38)
        let bQueen = Model(name: "B_Queen", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 39)
        let bRook1 = Model(name: "B_Rook_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 40)
        let bRook2 = Model(name: "B_Rook_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 41)
        
        let wBishop1 = Model(name: "W_Bishop_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 42)
        let wBishop2 = Model(name: "W_Bishop_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 43)
        let wKing = Model(name: "W_King", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 44)
        let wKnight1 = Model(name: "W_Knight_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 45)
        let wKnight2 = Model(name: "W_Knight_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 46)
        let wPawn1 = Model(name: "W_Pawn_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 47)
        let wPawn2 = Model(name: "W_Pawn_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 48)
        let wPawn3 = Model(name: "W_Pawn_3", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 49)
        let wPawn4 = Model(name: "W_Pawn_4", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 50)
        let wPawn5 = Model(name: "W_Pawn_5", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 51)
        let wPawn6 = Model(name: "W_Pawn_6", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 52)
        let wPawn7 = Model(name: "W_Pawn_7", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 53)
        let wPawn8 = Model(name: "W_Pawn_8", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 54)
        let wQueen = Model(name: "W_Queen", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 55)
        let wRook1 = Model(name: "W_Rook_1", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 56)
        let wRook2 = Model(name: "W_Rook_2", category: .set, scaleCompensation: 2/10000, childs: [], assetID: 57)
        
        let chessBoard = Model(name: "Chess Board", category: .set, scaleCompensation: 2/10000, childs: [bBishop1, bBishop2, bKing, bKnight1, bKnight2, bPawn1, bPawn2, bPawn3, bPawn4, bPawn5, bPawn6, bPawn7, bPawn8, bQueen, bRook1, bRook2, wBishop1, wBishop2, wKing, wKnight1, wKnight2, wPawn1, wPawn2, wPawn3, wPawn4, wPawn5, wPawn6, wPawn7, wPawn8, wQueen, wRook1, wRook2], assetID: 58)
        
        ModelLibrary.currentAssets += [checkersBoard, chessBoard]
        
                        // Set Models
        let chess = Model(name: "Chess", category: .board, scaleCompensation: 2/10000, childs: [], assetID: 59)
        let modernCheckers = Model(name: "Modern Checkers", category: .board, scaleCompensation: 1/2, childs: [], assetID: 60)
        let vintageCheckers = Model(name: "Vintage Checkers", category: .board, scaleCompensation: 1/5000, childs: [], assetID: 61)
        
        ModelLibrary.currentAssets += [chess, modernCheckers, vintageCheckers, floor]
        
                       // Pieces
        // Checkers
        let blackCheckersPiece = Model(name: "Black_Piece", category: .pieces, scaleCompensation: 1/1, childs: [], assetID: 62)
        let redCheckersPiece = Model(name: "Red_Piece", category: .pieces, scaleCompensation: 1/1, childs: [], assetID: 63)
        
        // Chess
        let bBishop = Model(name: "B_Bishop", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 64)
        let bKnight = Model(name: "B_Knight", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 65)
        let bPawn = Model(name: "B_Pawn", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 66)
        let bRook = Model(name: "B_Rook", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 67)
        let blackKing = Model(name: "Black_King", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 68)
        let blackQueen = Model(name: "Black_Queen", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 69)
        
        let wBishop = Model(name: "W_Bishop", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 70)
        let wKnight = Model(name: "W_Knight", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 71)
        let wPawn = Model(name: "W_Pawn", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 72)
        let wRook = Model(name: "W_Rook", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 73)
        let whiteKing = Model(name: "White_King", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 74)
        let whiteQueen = Model(name: "White_Queen", category: .pieces, scaleCompensation: 2/10000, childs: [], assetID: 75)
        
        ModelLibrary.currentAssets += [blackCheckersPiece, redCheckersPiece, bBishop, bKnight, bPawn, bRook, blackKing, blackQueen, wBishop, wKnight, wPawn, wRook, whiteKing, whiteQueen]
        
                       // Figures
        let dripGoku = Model(name: "Drip Goku", category: .figures, scaleCompensation: 1/1500, childs: [], assetID: 76)
        let goku = Model(name: "Goku", category: .figures, scaleCompensation: 1/500, childs: [], assetID: 77)
        
        ModelLibrary.currentAssets += [dripGoku, goku]
        
    }
}
