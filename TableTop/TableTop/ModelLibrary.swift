//
//  ModelLibrary.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import Foundation

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
    // downloads models -- within this function, we should create the array after downloading
    // holds an array of model entities

    var currentAssets: [Model] = []

    init(){
        }

    // Download assets
}
