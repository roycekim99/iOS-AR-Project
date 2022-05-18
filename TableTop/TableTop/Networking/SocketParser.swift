//
//  SocketParser.swift
//  TableTop
//
//  Created by Nueton Huynh on 5/14/22.
//

import Foundation

// This class will help convert data received from the socket events.
// The listener returns an Arrays of Any, where SocketParser converts
// this information to a generic type.
class SocketParser {
    static func convert<T: Decodable>(data: Any) throws -> T {
        print ("DEBUG:: convert with regular input")
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        print("DEBUG:: Printing jsonData", jsonData)
        let decoder = JSONDecoder()
        
        print("DEBUG:: decoded data?")
        
        return try decoder.decode(T.self, from: jsonData)
    }
    
    static func convert<T: Decodable>(datas: [Any]) throws -> [T] {
        return try datas.map { (dict) -> T in
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        }
    }
    
}
