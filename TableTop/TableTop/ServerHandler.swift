//
//  ServiceManager.swift
//  TableTop
//
//  Created by Nueton Huynh on 5/2/22.
//

import SwiftUI
import SocketIO

final class ServerHandler: ObservableObject {
    // Configure SocketManager with socker server URL and show log on console
    private var manager = SocketManager(socketURL: URL(string: "http://35.161.104.204:3001/")!, config: [.log(true), .compress])
    var socket: SocketIOClient? = nil
    
    init() {
        // Initialize the socket (a SocketIOClient) variable, used to emit and listen to events.
        self.socket = manager.defaultSocket
        setupSocketEvents()
        
        socket?.connect()
        //DEBUG
        self.testEmission()
    }
    
    //DEBUG
    func testEmission(){
        let testModel = SharedSessionData(objectID: 0, modelName: "Test Object", position: [0.1, 0.5])
        
        emitOnTap(data: testModel)
        emitModelPlaced(data: testModel)
        emitModelTransformed(data: testModel)
        print("DEBUG:: Debug testEmissions called!!")
    }
    // Configures the event observers and socket events
    func setupSocketEvents() {
        // Default event
        socket?.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
            self.socket?.emit("New player joined", "NHUYA")
            self.testEmission()
        }
        
        // TODO: - Setup events for actions
        socket?.on("model-tapped") { (data, ack) in
            print ("DEBUG:: from server--> model tapped received")
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
                print("DEBUG:: Server requested to tap model: " + response.modelName)
            }
        }
        
        socket?.on("model-placed") { (data, ack) in
            print ("DEBUG:: from server--> model placed received")
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
                print("DEBUG:: Server requested to place model: " + response.modelName)
            }
        }
        
        socket?.on("model-transformed") { (data, ack) in
            print ("DEBUG:: from server--> model transform received")
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
                print("DEBUG:: Server requested to transform model: " + response.modelName)
            }
        }
    }
    
    
    // MARK: - Socket Emits
    
    // Convert the SharedSession object to a String:Any dictionary
    // Then emit with proper message and data.
    func emitOnTap(data: SharedSessionData) {
        
        let info: [String : Any] = [
            "objectID": Int(data.objectID),
            "modelName": String(data.modelName),
            "position": [Float](data.position)
        ]
        
        self.socket?.emit("model-tapped", info)
    }
    
    func emitModelPlaced(data: SharedSessionData){
       
        let info: [String : Any] = [
            "objectID": Int(data.objectID),
            "modelName": String(data.modelName),
            "position": [Float](data.position)
        ]
        self.socket?.emit("model-placed", info)
    }
    
    func emitModelTransformed(data: SharedSessionData){
        let info: [String : Any] = [
            "objectID": Int(data.objectID),
            "modelName": String(data.modelName),
            "position": [Float](data.position)
        ]
        self.socket?.emit("model-transformed", info)
    }
    
//    private func getSharedSessionData(from model: Model){
//        return [String : Any] = [
//            "objectID": Int(model.assetID),
//            "modelName": String(model.name),
//            "position": [0.0,0.0]
//        ]
//    }
    // Call this when ending a session.
    func stop() {
        socket?.removeAllHandlers()
    }
}


// This class will help convert data received from the socket events.
// The listener returns an Arrays of Any, where SocketParser converts
// this information to a generic type.
class SocketParser {
    static func convert<T: Decodable>(data: Any) throws -> T {
        print ("DEBUG:: convert with regular input")

        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
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


// Class to hold information about the game session we want to send/receive from server
struct SharedSessionData: Codable {
    var objectID: Int
    var modelName: String
    var position: [Float]
}

