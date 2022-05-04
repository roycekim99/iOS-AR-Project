//
//  ServiceManager.swift
//  TableTop
//
//  Created by Nueton Huynh on 5/2/22.
//

import Foundation
import SwiftUI
import SocketIO

final class ServiceManager: ObservableObject {
    weak var delegate: SocketSessionManagerDelegate?
    
    // Configure SocketManager with socker server URL and show log on console
    private var manager = SocketManager(socketURL: URL(string: "http://35.161.104.204:3001/")!, config: [.log(true), .compress])
    
    var socket: SocketIOClient? = nil

    @Published var messages = [String]()
    
    
    init(_ delegate: SocketSessionManagerDelegate) {
        self.delegate = delegate
        // Initialize the socket (a SocketIOClient) variable, used to emit
        // and listen to events.
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
        
        // Custom event
        socket?.on("iOS Client Port") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String],
            let rawMessage = data["msg"] {
                DispatchQueue.main.async {
                    self?.messages.append(rawMessage)
                }
            }
        }
        // TODO: - Setup events for actions here like this???????
//        socket?.on("drawing") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            if let response: SocketPosition = try? SocketParser.convert(data: dataInfo) {
//                let position = CGPoint.init(x: response.x, y: response.y)
//                self.delegate?.didReceive(point: position)
//            }
//        }

    }
    
    // Convert the SharedSession object to a String:Any dictionary
    // Then emit with proper message and data.
    func socketChanged(position: SharedSessionData) {
//        let info: [String : Any] = [
//            "x": Double(position.x),
//            "y": Double(position.y)
//        ]
//        socket?.emit("drawing", info)
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
    var tempVar: Double
    //positon, model name, Object ID
}

// Protocol for the controller of the module to receive information of the Socket class.
// Logic for didReceive will vary per action(onTap, onPlace, transforms, etc.)
protocol SocketSessionManagerDelegate: class {
    func didConnect()
    func didReceive(gameSession: SharedSessionData)
}
