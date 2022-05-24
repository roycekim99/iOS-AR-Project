/*
 Abstract:
 ServerHandler handles connection to the server.
 Implemented with singleton design pattern.
 */

import SwiftUI
import SocketIO
import UIKit
import AlertToast


final class ServerHandler {
    private static var SHInstane = ServerHandler()
    
    // Configure SocketManager with socker server URL and show log on console
    private var manager = SocketManager(socketURL: URL(string: "http://35.161.104.204:3001/")!, config: [.log(true), .compress])
    var socket: SocketIOClient? = nil
    var userName = ""
    var client_userName = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    @ObservedObject private var messageManager = MessageManager.messageInstance
    
    init() {
        // Initialize the socket (a SocketIOClient) variable, used to emit and listen to events.
        print("DEBUG:: ServerHandler|| INIT!!!")
        self.socket = manager.defaultSocket
        setupSocketEvents()
        
        socket?.connect()
        self.setUserName(newName: ModelLibrary.username)
        //        self.emitRequestForPlayerList()
    }
    
    // MARK: DEBUG
    //    func testEmission(){
    //        let testModel = SharedSessionData(username: ModelLibrary.username, objectID: "Test ID", modelName: "Test Object", position: [0.1, 0.5])
    //        let testModel = SharedSessionData(modelUID: "Test ID", modelName: "Test Object", position: SIMD3<Float>())
    //
    //        emitOnTap(data: testModel)
    //        emitModelPlaced(data: testModel)
    //        emitModelTransformed(data: testModel)
    //        print("DEBUG:: Debug testEmissions called!!")
    //    }
    
    func setUserName(newName: String) {
        self.userName = newName
        self.client_userName += ":" + newName
    }
    
    func getClientUserName() -> String {
        return self.client_userName
    }
    
    static func getInstance() -> ServerHandler {
        return SHInstane
    }
    
    
    // MARK: SETUP LISTENERS
    // Configures the event observers and socket events
    func setupSocketEvents() {
        // Default event
        socket?.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
        
            self.socket?.emit("New player joined", self.client_userName)
            
            self.socket?.emit("playerList-req", " ")
        }
        
        socket?.on(clientEvent: .disconnect) { (data, ack) in
            print ("You've been disconnected!")
            //            guard let dataInfo = data.first else { return } // TODO: HANDLE LATER
            self.socket?.emit("playerList-req", " ")
        }
        
        self.socket?.on("New player joined") { (data, ack) in
            
            guard let dataInfo = data.first else {return}
            print("TESTING:: receving user name \(dataInfo)")
            
            self.messageManager.show = true
            self.messageManager.alertToast = AlertToast(displayMode: .hud, type: .regular, title: "\(dataInfo) has joined")
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
            print ("DEBUG:: FROM SERVER -> model-placed received")
            guard let dataInfo = data.first else { return }
            
            // Parse data from server
            let dataDict = dataInfo as! [String: Any]
            
            self.messageManager.show = true
            self.messageManager.alertToast = AlertToast(displayMode: .hud, type: .regular, title: "\(dataDict["modelName"]! as! String) has been placed")
            
            let tempSharedSessionData = SharedSessionData(
                modelUID: dataDict["objectID"]! as! String,
                modelName: dataDict["modelName"]! as! String,
                positionX: (dataDict["positionX"] as! NSNumber).floatValue,
                positionY: (dataDict["positionY"] as! NSNumber).floatValue,
                positionZ: (dataDict["positionZ"] as! NSNumber).floatValue)
            
            // Hard coded y-value temporarily to fix receiving users objects falling
            let positionArr = [tempSharedSessionData.positionX,
                               0.3,
                               tempSharedSessionData.positionZ]
            
            print("DEBUG:: SH modelName ->>>>", tempSharedSessionData.modelName)
            
            if let foundModel = ModelLibrary().getModelWithName(modelName: tempSharedSessionData.modelName) {
                let reqPosSIMD3 = SIMD3<Float>(positionArr)
                print("DEBUG:: SH INSIDE OF IF FOUNDMODEL")
                
                let clonedModelFromRequest =
                ModelLibrary().getModelCloned(from: foundModel)
                
                ModelManager.getInstance().place(for: clonedModelFromRequest, reqPos: reqPosSIMD3)
                ModelManager.getInstance().addActiveModel(modelID: clonedModelFromRequest.model_uid, model: clonedModelFromRequest)
            } else {
                print("DEBUG:: SH || unable to find model with requested name, failed requested placement!!")
            }
        }
        
        self.socket?.on("model-selected") { (data, ack) in
            print("DEBUG:: a model has been selected -> load model now")
            
            guard let dataInfo = data.first else {return}
            if let response: SelectedModel = try? SocketParser.convert(data: dataInfo) {
                let selectedModel = ModelLibrary().getModelWithName(modelName: response.selectedModelName)
                ModelManager.getInstance().loadIfNotLoaded(model: selectedModel!)
            }
        }
        
        
        self.socket?.on("model-transformed") { (data, ack) in
            print ("DEBUG:: from server--> model transform received")
            
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
                print("DEBUG:: Server requested to transform model: " + response.modelName)
                
                //parse data from server
                let dataDict = dataInfo as! [String: Any]
                
                let incomingData = SharedSessionData(
                    modelUID: dataDict["objectID"]! as! String,
                    modelName: dataDict["modelName"]! as! String,
                    positionX: (dataDict["positionX"] as! NSNumber).floatValue,
                    positionY: (dataDict["positionY"] as! NSNumber).floatValue,
                    positionZ: (dataDict["positionZ"] as! NSNumber).floatValue)
                
                let positionArr = [incomingData.positionX,
                                   incomingData.positionY,
                                   incomingData.positionZ]
                
                //DEBUG
                print("DEBUG:: SH modelName ->>>>", incomingData.modelName)
            
                //1. find model from active models
                if let activeModel = ModelManager.getInstance().activeModels[incomingData.modelUID]{
                    ModelManager.getInstance().moveModel(model: activeModel, to: SIMD3<Float>(positionArr))
                } else {
                    print("DEBUG:: SH || no model found to move!!!!")
                }
                
            }
        }
        
        
        self.socket?.on("playerList-req") { (data, ack) in
            print("DEBUG:: SH PLAYER || FROM SERVER -> received new list of users")
            
            guard let playerNames = data.first as? String else {return}
            print("DEBUG:: SH PLAYER || playerNames: ", playerNames.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            print("DEBUG:: SH PLAYER || playerNames: ", type(of: playerNames))
            //            print("DEBUG:: SH PLAYER || playerNames: ", playerNames.)
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
    
    func emitSelectedModel(data: SelectedModel) {
        let info: [String: Any] = [
            "selectedModelName" : String(data.selectedModelName)
        ]
        
        self.socket?.emit("model-selected", info)
    }
    
    //    func emitRequestForPlayerList(){
    //        print("DEBUG:: SH|| now asking for player list")
    //        socket?.emit("playerList-req", " ")
    //    }
    
    
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


struct SelectedModel: Codable {
    var selectedModelName: String
}

struct PlayerConnectionsFromServer: Codable {
    var playerNames: [String]
}

class PlayerList: ObservableObject {
    @Published var playerNames = [String]()
}
