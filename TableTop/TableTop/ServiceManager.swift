//
//  ServiceManager.swift
//  TableTop
//
//  Created by Nueton Huynh on 5/2/22.
//

import SwiftUI
import SocketIO

final class ServiceManager: ObservableObject {
    // Configure SocketManager with socker server URL and show log on console
    private var manager = SocketManager(socketURL: URL(string: "http://35.161.104.204:3001/")!, config: [.log(true), .compress])
    weak var delegate: SocketSessionManagerDelegate?
    var socket: SocketIOClient? = nil
    
    init() {
        // Initialize the socket (a SocketIOClient) variable, used to emit and listen to events.
        self.socket = manager.defaultSocket
        setupSocketEvents()
        socket?.connect()
    }
    
    // Configures the event observers and socket events
    func setupSocketEvents() {
        // Default event
        socket?.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
            self.socket?.emit("NodeJS Server Port", "Hi Node.js server.")
        }
        
        // TODO: - Setup events for actions
        socket?.on("model-tapped") { (data, ack) in
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
//                let position = CGPoint.init(x: response.x, y: response.y)
//                self.delegate?.didReceive(point: position)
                print("DEBUG:: ")
            }
        }
        
        socket?.on("model-placed") { (data, ack) in
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
//                let position = CGPoint.init(x: response.x, y: response.y)
//                self.delegate?.didReceive(point: position)
                print("DEBUG:: ")
            }
        }
        
        socket?.on("model-transformed") { (data, ack) in
            guard let dataInfo = data.first else { return }
            if let response: SharedSessionData = try? SocketParser.convert(data: dataInfo) {
//                let position = CGPoint.init(x: response.x, y: response.y)
//                self.delegate?.didReceive(point: position)
                print("DEBUG:: ")
            }
        }
    }
    
    
    // MARK: - Socket Emits
    
    // Convert the SharedSession object to a String:Any dictionary
    // Then emit with proper message and data.
    func emitOnTap(data: SharedSessionData) {
        let info: [String : Any] = [
            "objectID": Int(data.ObjectID),
            "modelName": String(data.modelName),
            "position": [Double](data.position)
        ]
        socket?.emit("onTap", info)
    }
    
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
    var ObjectID: Int
    var modelName: String
    var position: [Double]
}

