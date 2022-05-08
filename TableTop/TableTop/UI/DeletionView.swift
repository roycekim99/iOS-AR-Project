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
            print("DEBUG:: Setting Deletion Enabled to \(String(describing: newValue.description))")
            CustomARView.Holder.deletionEnabled = newValue
        }
    }
    
    @Published var entitySelectedForDeletion: ModelEntity? = nil {
        willSet(newValue) {
            
            if self.entitySelectedForDeletion == nil, let newlySelectedModelEntity = newValue {
                print("DEBUG:: Selecting new entitySelectedForDeletion, no prior selection.")
                
                // Highlight newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
                
                
            } else if let previouslySelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue {
                print("DEBUG:: Selecting new entitySelectedForDeletion, had a prior selection.")
                
                // Un-highlight previouslySelectedModelEntity
                previouslySelectedModelEntity.modelDebugOptions = nil
                
                // Highlight newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
                
                
            } else if newValue == nil {
                print("DEBUG:: Clearing entitySelectedForDeletion.")
                
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
                
                guard let modelSelectedToDelete = self.deletionManager.entitySelectedForDeletion else { return }
                guard let anchorSelectedToDelete = self.deletionManager.entitySelectedForDeletion?.anchor else { return }
                
                
                let anchoringIdentifier = anchorSelectedToDelete.anchorIdentifier
                
                if let modelForDeletion = ModelManager.getInstance().activeModels.first(where: {$0.value.getAnchorEntity().anchorIdentifier == anchoringIdentifier}){
                    print("DEBUG:: found anchor to delete!")
                    
                    ModelManager.getInstance().activeModels.removeValue(forKey: modelForDeletion.key)
                }
                
                anchorSelectedToDelete.removeFromParent()
                self.deletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()

        }
        .padding(.bottom, 45)
        
        HStack {
            Spacer()
            
            DeleteAll() {
                print("Delete All button pressed.")
                
                for (_,model) in ModelManager.getInstance().activeModels {
                    let anchorEntity = model.getAnchorEntity()
                    print("Deleting anchorEntity with id: \(String(describing: anchorEntity.anchorIdentifier))")
                    
                    anchorEntity.removeFromParent()
                    anchorEntity.children.removeAll()
                }
                
                //TODO: might not need
                ModelManager.getInstance().activeModels.removeAll()
            }
            
            Spacer()
        }
        .padding(.bottom, 20)
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

struct DeleteAll: View {
    let action: () -> Void
    
    var body: some View {
        Button("Delete All", action: {
            self.action()
        })
        .font(.system(size: 16, weight: .semibold, design: .default))
        .foregroundColor(.white)
        .buttonStyle(.bordered)
        .tint(.black)
        .frame(maxWidth: 200)
    }
    
}
