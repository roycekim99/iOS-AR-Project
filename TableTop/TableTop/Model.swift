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
    case set
    case board
    case pieces
    case figures
    case idk
    
    var label: String {
        get {
            switch self {
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


class Model {
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
    
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

struct Models {
    var all: [Model] = []
    
    init() {
        // Sets
        let checkersBoard = Model(name: "Checkers Board", category: .set, scaleCompensation: 10/100)
        let blackPiece1 = Model(name: "Black 1", category: .set, scaleCompensation: 10/100)
        
        self.all += [checkersBoard, blackPiece1]
        // Games
        let chessSet = Model(name: "Chess Set", category: .board, scaleCompensation: 5/100)
        let checkers = Model(name: "Checkers", category: .board, scaleCompensation: 1/100)
        
        self.all += [chessSet, checkers]
        
        // Pieces
        let blackCheckersPiece = Model(name: "Black Piece", category: .pieces, scaleCompensation: 10/100)
        let redCheckersPiece = Model(name: "Red Piece", category: .pieces, scaleCompensation: 10/100)
        
        self.all += [blackCheckersPiece, redCheckersPiece]
        // Figures
        let goku = Model(name: "Goku", category: .figures, scaleCompensation: 10/100)
        let goku_drip = Model(name: "Goku_Drip", category: .figures, scaleCompensation: 100/100)
        
        self.all += [goku, goku_drip]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter( {$0.category == category})
    }
}
