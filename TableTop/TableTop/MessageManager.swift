//
//  MessageManager.swift
//  TableTop
//
//  Created by Ashley Li on 5/16/22.
//

import Foundation
import AlertToast

class MessageManager: ObservableObject {
    static let messageInstance = MessageManager()
    
    @Published var show = false {
        willSet(newValue) {
            print("current showvalue is \(show)")
            print("setting showValue to \(newValue)")
        }
        
        didSet {
            print("now showValue is \(show)")
        }
    }
    
    @Published var alertToast = AlertToast(displayMode: .hud, type: .regular, title: " ")

}
