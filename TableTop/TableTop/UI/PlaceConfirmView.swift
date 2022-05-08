//
//  PlaceConfirmView.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

import SwiftUI

struct PlaceConfirmView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    var isOriginPoint = false
    
    init(isOrigin: Bool){
        self.isOriginPoint = isOrigin
    }
    
    // View to place object
    var body: some View {
        HStack {
            Spacer()
            
            if isOriginPoint == false {
                PlacementButton(systemIconName: "xmark.circle.fill") {
                    print("DEBUG:: Cancel Placement Button pressed.")
                    self.placementSettings.selectedModel = nil
                }
                
                Spacer()
            }
            
            
            PlacementButton(systemIconName: "checkmark.circle.fill") {
                print("DEBUG:: Confirm Placement button pressed.")
                
                self.placementSettings.confirmedModel = self.placementSettings.selectedModel
                
                // record id only when the object is comfirmed
                self.placementSettings.confirmedModelID = self.placementSettings.selectedModelID
                
                self.placementSettings.selectedModel = nil
                self.placementSettings.selectedModelID = nil
            }
            Spacer()
        }
        .padding(.bottom, 45)
    }
}

struct PlacementButton: View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size:50, weight: .light, design: .default))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75)
    }
}

