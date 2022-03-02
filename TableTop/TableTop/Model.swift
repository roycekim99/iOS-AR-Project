//
//  Model.swift
//  TableTop
//
//  Created by Jet Aung on 2/1/22.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: CaseIterable {
    case test
    case set
    case board
    case pieces
    case figures
    case idk
    
    var label: String {
        get {
            switch self {
            case .test:
                return "Tests"
            case .set:
                return "Sets"
            case .board:
                return "Boards"
            case .pieces:
                return "Pieces"
            case .figures:
                return "Figures"
            case .idk:
                return "I Don't Know"
            }
        }
    }
}

// Model object class
class Model {
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    var childs: [Model]
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0, childs: [Model]) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        self.childs = childs
    }
    
    // Load models asynchronously for seamless gameplay
    func asyncLoadModelEntity() {
        let filename = self.name + ".usdz"
        
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                
                switch loadCompletion {
                case .failure(let error): print("Unable to load modelEntity for \(filename). Error \(error.localizedDescription)")
                case .finished:
                    break
                }
                
            }, receiveValue: { modelEntity in
                
                self.modelEntity = modelEntity
                self.modelEntity?.scale *= self.scaleCompensation
                
                print("modelEntity for \(self.name) has been loaded.")
                
            })
        
    }
}

// Import models into TableTop App
struct Models {
    // Hard coded and hard to read. Clean up in the future
    
    var all: [Model] = []
    
    init() {
        // Tests
        let black1 = Model(name: "Black_1", category: .test, scaleCompensation: 1/1, childs: [])
        let black2 = Model(name: "Black_2", category: .test, scaleCompensation: 1/1, childs: [])
        let black3 = Model(name: "Black_3", category: .test, scaleCompensation: 1/1, childs: [])
        let black4 = Model(name: "Black_4", category: .test, scaleCompensation: 1/1, childs: [])
        let black5 = Model(name: "Black_5", category: .test, scaleCompensation: 1/1, childs: [])
        let black6 = Model(name: "Black_6", category: .test, scaleCompensation: 1/1, childs: [])
        let black7 = Model(name: "Black_7", category: .test, scaleCompensation: 1/1, childs: [])
        let black8 = Model(name: "Black_8", category: .test, scaleCompensation: 1/1, childs: [])
        let black9 = Model(name: "Black_9", category: .test, scaleCompensation: 1/1, childs: [])
        let black10 = Model(name: "Black_10", category: .test, scaleCompensation: 1/1, childs: [])
        let black11 = Model(name: "Black_11", category: .test, scaleCompensation: 1/1, childs: [])
        let black12 = Model(name: "Black_12", category: .test, scaleCompensation: 1/1, childs: [])
        let red1 = Model(name: "Red_1", category: .test, scaleCompensation: 1/1, childs: [])
        let red2 = Model(name: "Red_2", category: .test, scaleCompensation: 1/1, childs: [])
        let red3 = Model(name: "Red_3", category: .test, scaleCompensation: 1/1, childs: [])
        let red4 = Model(name: "Red_4", category: .test, scaleCompensation: 1/1, childs: [])
        let red5 = Model(name: "Red_5", category: .test, scaleCompensation: 1/1, childs: [])
        let red6 = Model(name: "Red_6", category: .test, scaleCompensation: 1/1, childs: [])
        let red7 = Model(name: "Red_7", category: .test, scaleCompensation: 1/1, childs: [])
        let red8 = Model(name: "Red_8", category: .test, scaleCompensation: 1/1, childs: [])
        let red9 = Model(name: "Red_9", category: .test, scaleCompensation: 1/1, childs: [])
        let red10 = Model(name: "Red_10", category: .test, scaleCompensation: 1/1, childs: [])
        let red11 = Model(name: "Red_11", category: .test, scaleCompensation: 1/1, childs: [])
        let red12 = Model(name: "Red_12", category: .test, scaleCompensation: 1/1, childs: [])

        let checkersBoard = Model(name: "Checkers Board", category: .test, scaleCompensation: 1/1, childs: [black1, black2, black3, black4, black5, black6, black7, black8, black9, black10, black11, black12, red1, red2, red3, red4, red5, red6, red7, red8, red9, red10, red11, red12])
        self.all += [checkersBoard]
        // Sets
        // Games
        let chessSet = Model(name: "Chess Set", category: .board, scaleCompensation: 5/100, childs: [])
        let checkers = Model(name: "Checkers", category: .board, scaleCompensation: 1/100, childs: [])
        
        self.all += [chessSet, checkers]
        
        // Pieces
        let blackCheckersPiece = Model(name: "Black Piece", category: .pieces, scaleCompensation: 10/100, childs: [])
        let redCheckersPiece = Model(name: "Red Piece", category: .pieces, scaleCompensation: 10/100, childs: [])
        
        self.all += [blackCheckersPiece, redCheckersPiece]
        // Figures
        let goku = Model(name: "Goku", category: .figures, scaleCompensation: 10/100, childs: [])
        let goku_drip = Model(name: "Goku_Drip", category: .figures, scaleCompensation: 100/100, childs: [])
        
        self.all += [goku, goku_drip]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter( {$0.category == category})
    }
}
