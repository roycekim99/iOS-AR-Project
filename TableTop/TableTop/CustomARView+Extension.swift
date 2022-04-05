//
//  CustomARView+Extension.swift
//  TableTop
//
//  Created by Nueton Huynh on 4/5/22.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import MultipeerHelper
import MultipeerConnectivity
import Combine

import Foundation

extension CustomARView: MultipeerHelperDelegate {
    
    func shouldSendJoinRequest(_ peer: MCPeerID, with discoveryInfo: [String : String]?) -> Bool {
        if CustomARView.checkPeerToken(with: discoveryInfo) {
            return true
        }
        print("incompatible peer!")
        return false
    }
    
    func setupMultipeer() {
        multipeerHelp = MultipeerHelper(
            serviceName: "helper-test",
            sessionType: .both,
            delegate: self
        )
        
        // MARK: - Setting RealityKit Synchronization
        
        guard let syncService = multipeerHelp.syncService else {
            fatalError("could not create multipeerHelp.syncService")
        }
        self.scene.synchronizationService = syncService
    }
    
    func receivedData(_ data: Data, _ peer: MCPeerID) {
        print(String(data: data, encoding: .unicode) ?? "Data is not a unicode string")
    }
    
    func peerJoined(_ peer: MCPeerID) {
        print("new peer has joined:")
    }
}
