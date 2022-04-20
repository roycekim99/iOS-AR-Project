//
//  DeletionView.swift
//  TableTop
//
//  Created by Jet Aung on 4/20/22.
//

import SwiftUI
import RealityKit

class DeletionManager: ObservableObject {
    @Published var DeletionEnabled: Bool = false {
        willSet(newValue) {
            print("Setting Deletion Enabled to \(String(describing: newValue.description))")
            CustomARView.Holder.deletionEnabled = newValue
        }
    }
    
    @Published var entitySelectedForDeletion: ModelEntity? = nil {
        willSet(newValue) {
            if self.entitySelectedForDeletion == nil, let newlySelectedModelEntity = newValue {
                print("Selecting new entitySelectedForDeletion, no prior selection.")
                
                // Highlight newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if let previouslySelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue {
                print("Selecting new entitySelectedForDeletion, had a prior selection.")
                
                // Un-highlight previouslySelectedModelEntity
                previouslySelectedModelEntity.modelDebugOptions = nil
                
                // Highlight newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if newValue == nil {
                print("Clearing entitySelectedForDeletion.")
                
                self.entitySelectedForDeletion?.modelDebugOptions = nil
            }
        }
    }
}

struct DeletionView: View {
    @EnvironmentObject var deletionManager: DeletionManager
    @Binding var deleteEnabled: Bool
    var body: some View {
        HStack {
            Spacer()
            
            DeleteButton(systemIconName: "xmark.circle.fill") {
                print("Cancel Deletion button pressed.")
                self.deleteEnabled = false
                self.deletionManager.DeletionEnabled = false
                self.deletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()
            
            DeleteButton(systemIconName: "trash.circle.fill") {
                print("Confirm Deletion button pressed.")
                
                guard let anchor = self.deletionManager.entitySelectedForDeletion?.anchor else { return }
                
                let anchoringIdentifier = anchor.anchorIdentifier
                if let index = ARSceneManager.anchorEntities.firstIndex(where: { $0.anchorIdentifier == anchoringIdentifier}) {
                    print("Deleting anchorEntity with id: \(String(describing: anchoringIdentifier))")
                    ARSceneManager.anchorEntities.remove(at: index)
                }
                
                anchor.removeFromParent()
                self.deletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct DeleteButton: View {
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
