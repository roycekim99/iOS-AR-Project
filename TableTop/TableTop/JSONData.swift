//
//  JSONData.swift
//  TableTop
//
//  Created by Royce Kim on 3/7/22.
//

struct JSONData: Codable{
    let modelName,command: String
//    let modelUID: String
    let parameters: [String]
    
    
    enum CodingKeys : String, CodingKey {
        case modelName = "modelName"
//        case modelUID = "lastname"
        case command = "command"
        case parameters;
    }
    
}
