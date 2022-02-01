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
    case games
    case pieces
    case figures
    case idk
    
    var label: String {
        get {
            switch self {
            case .games:
                return "Games"
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
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
    
    //TODO: Create a method to async load modelEntity
    func asyncLoadModelEntity() {
        let filename = self.name + ".usdz"
        
        
    }
}

struct Models {
    var all: [Model] = []
    
    init() {
        // Games
        let chessSet = Model(name: "Chess Set", category: .games, scaleCompensation: 0.32/100)
        let checkersSet = Model(name: "Checkers Set", category: .games, scaleCompensation: 0.32/100)
        
        self.all += [chessSet, checkersSet]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter( {$0.category == category})
    }
}
