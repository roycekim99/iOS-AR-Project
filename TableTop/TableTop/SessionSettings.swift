//
//  SessionSettings.swift
//  TableTop
//
//  Created by Jet Aung on 2/4/22.
//

import SwiftUI

// State variables for setting toggles
class SessionSettings: ObservableObject {
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isMultiuserEnabled: Bool = false
}
