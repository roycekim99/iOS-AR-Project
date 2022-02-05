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
    case pieces
    case figures
    case idk
    
    var label: String {
        get {
            switch self {
            case .set:
                return "Set"
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
        // Games
        let chessSet = Model(name: "Chess Set", category: .set, scaleCompensation: 5/100)
        let checkersSet = Model(name: "Checkers Set", category: .set, scaleCompensation: 1/100)
        
        self.all += [chessSet, checkersSet]
        
        // Figures
        let goku = Model(name: "Goku", category: .figures, scaleCompensation: 10/100)
        let goku_drip = Model(name: "Goku_Drip", category: .figures, scaleCompensation: 100/100)
        
        self.all += [goku, goku_drip]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter( {$0.category == category})
    }
}
