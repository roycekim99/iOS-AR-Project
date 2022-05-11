//
//  ServiceManager.swift
//  TableTop
//
//  Created by Nueton Huynh on 5/2/22.
//

import SwiftUI
import SocketIO
import UIKit


final class ServerHandler {
    private static var SHInstane = ServerHandler()
    
    // Configure SocketManager with socker server URL and show log on console
    private var manager = SocketManager(socketURL: URL(string: "http://35.161.104.204:3001/")!, config: [.log(true), .compress])
    var socket: SocketIOClient? = nil
    
    var userName = ""
    var client_userName = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    init() {
        // Initialize the socket (a SocketIOClient) variable, used to emit and listen to events.
        print("DEBUG:: ServerHandler|| INIT!!!")
        self.socket = manager.defaultSocket
        setupSocketEvents()
        
        socket?.connect()
        self.setUserName(newName: ModelLibrary.username)
        self.emitRequestForPlayerList()
    }
    
    // MARK: DEBUG
//    func testEmission(){
////        let testModel = SharedSessionData(username: ModelLibrary.username, objectID: "Test ID", modelName: "Test Object", position: [0.1, 0.5])
//        let testModel = SharedSessionData(modelUID: "Test ID", modelName: "Test Object", position: SIMD3<Float>())
//
//        emitOnTap(data: testModel)
//        emitModelPlaced(data: testModel)
//        emitModelTransformed(data: testModel)
//        print("DEBUG:: Debug testEmissions called!!")
//    }
    
    func setUserName(newName: String){
        self.userName = newName
        self.client_userName += ":" + newName
    }
    
    func getClientUserName() -> String {
        return self.client_userName
    }
    
    static func getInstance() -> ServerHandler{
        return SHInstane
    }
    
    
    // MARK: SETUP LISTENERS
    // Configures the event observers and socket events
    func setupSocketEvents() {
        // Default event
        socket?.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
            self.socket?.emit("New player joined", self.client_userName)
        }
        
        socket?.on(clientEvent: .disconnect) { (data, ack) in
            print ("You've been disconnected!")

            guard let dataInfo = data.first else { return }
        }

        
        self.socket?.on("model-tapped") { (data, ack) in
            print ("DEBUG:: from server--> model tapped received")
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
                print("DEBUG:: Server requested to tap model: " + response.modelName)
        }
        // Call function here to display the message
    }
        
        self.socket?.on("model-placed") { (data, ack) in
            print ("DEBUG:: FROM SERVER -> model placed received")
            guard let dataInfo = data.first else { return }

            let dataDict = dataInfo as! [String: Any]

            let tempSharedSessionData = SharedSessionData(
                modelUID: dataDict["objectID"]! as! String,
                modelName: dataDict["modelName"]! as! String,
                positionX: dataDict["positionX"] as! Float,
                positionY: dataDict["positionY"] as! Float,
                positionZ: dataDict["positionZ"] as! Float)
            
                let positionArr = [tempSharedSessionData.positionX,
                                   tempSharedSessionData.positionY,
                                   tempSharedSessionData.positionZ]

            if let foundModel = ModelLibrary().getModelWithName(modelName: tempSharedSessionData.modelName){
                let reqPosSIMD3 = SIMD3<Float>(positionArr)
                ModelManager.getInstance().place(for: foundModel, reqPos: reqPosSIMD3)
            } else {
                print("DEBUG:: SH || unable to find model with requested name, failed requested placement!!")
            }
            print("DEBUG:: tempSharedSessionData: ", tempSharedSessionData)
        }
    
        self.socket?.on("model-transformed") { (data, ack) in
            print ("DEBUG:: from server--> model transform received")
            
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
                print("DEBUG:: Server requested to transform model: " + response.modelName)
            }
        }
        
        self.socket?.on("playerList-req") { (data, ack) in
            print("DEBUG:: SH|| FROM SERVER -> received new list of users")
            
            guard let playerNames = data.first else {return}
            if let playerListData: PlayerConnectionsFromServer = try? SocketParser.convert(data: playerNames) {
                PlayerList().playerNames = playerListData.playerNames
                print("DEBUG:: SH|| list looks like: \(playerListData.playerNames)")
            }
        }

    }
    
    
    // MARK: SETUP SENDERS
    // Convert the SharedSession object to a String:Any dictionary
    // Then emit with proper message and data.
    func emitOnTap(data: SharedSessionData) {
        let info: [String : Any] = [
            "objectID": String(data.modelUID),
            "modelName": String(data.modelName),
            "position": Float(data.positionX),
            "position": Float(data.positionY),
            "position": Float(data.positionZ)
        ]
        
        self.socket?.emit("model-tapped", info)
    }
    
    func emitModelPlaced(data: SharedSessionData){
        let info: [String : Any] = [
            "objectID": String(data.modelUID),
            "modelName": String(data.modelName),
            "positionX": Float(data.positionX),
            "positionY": Float(data.positionY),
            "positionZ": Float(data.positionZ)
        ]
        socket?.emit("model-placed", info)
    }
    
    func emitModelTransformed(data: SharedSessionData){
        let info: [String : Any] = [
            "objectID": String(data.modelUID),
            "modelName": String(data.modelName),
            "positionX": Float(data.positionX),
            "positionY": Float(data.positionY),
            "positionZ": Float(data.positionZ)
        ]
        self.socket?.emit("model-transformed", info)
    }
    
    func emitRequestForPlayerList(){
        print("DEBUG:: SH|| now asking for player list")
        socket?.emit("playerList-req", " ")
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


// Class to hold information about the game session we want to send/receive from server
struct SharedSessionData: Codable {
    var modelUID: String
    var modelName: String
    var positionX: Float
    var positionY: Float
    var positionZ: Float
}

struct PlayerConnectionsFromServer: Codable {
    var playerNames: [String]
}

    
class PlayerList: ObservableObject {
    @Published var playerNames = [String]()
}

