//
//  ServiceManager.swift
//  TableTop
//
//  Created by Nueton Huynh on 5/2/22.
//

import Foundation
import SwiftUI
import SocketIO

final class Service: ObservableObject {
    private var manager = SocketManager(socketURL: URL(string: "http://35.161.104.204:3001/")!, config: [.log(true), .compress])

    @Published var messages = [String]()
    
    init() {
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
            socket.emit("NodeJS Server Port", "Hi Node.js server.")
        }
        
        socket.on("iOS Client Port") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String],
            let rawMessage = data["msg"] {
                DispatchQueue.main.async {
                    self?.messages.append(rawMessage)
                }
            }
        }
        
        socket.connect()
    }
    
    func sendModelData() {
        let socket = manager.defaultSocket
        socket.on("model-data") { data, ack in
            guard let dict = data[0] as? [String: Any] else {return}
            print(dict)
        }
    }
}
