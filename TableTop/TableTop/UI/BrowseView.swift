//
//  BrowseView.swift
//  TableTop
//
//  Created by Royce Kim on 4/7/22.
//

// TODO: update after finishing other classes

import SwiftUI

struct BrowseView: View {
    @Binding var showBrowse: Bool
    
    var body: some View {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    // Gridviews for thumbnails
                    RecentsGrid(showBrowse: $showBrowse)
                    ModelsByCategoryGrid(showBrowse: $showBrowse)
                }
                .navigationBarTitle(Text("Browse"), displayMode: .large)
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showBrowse.toggle()
                }) {
                    Text("Done").bold()
                })
            }
        }

}

struct ModelsByCategoryGrid: View {
    @Binding var showBrowse: Bool
    
    //get models in modelLibrary
    //need to nodify later depends on how we implement ModelLibrary class
    let models = ModelLibrary()
    
    var body: some View {
        VStack {
            // multiple horizontalGrid based on categories
            ForEach(ModelCategory.allCases, id: \.self) { category in
                
                // Only display grid if category contains items
                if let modelsByCategory = models.getCategory(category: category) {
                    HorizontalGrid(showBrowse: $showBrowse, title: category.label, modelLibrary: modelsByCategory)
                }
            }
        }
    }
}

struct RecentsGrid: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool

    var body: some View {
        if !self.placementSettings.recentlyPlaced.isEmpty {
            // create a horitzontalGrid for recentlyPlacedbject
            HorizontalGrid(showBrowse: $showBrowse, title: "Recents", modelLibrary: getRecentsUniqueOrdered())
        }
    }

    func getRecentsUniqueOrdered() -> [Model] {
        var recentsUniqueOrderedArray: [Model] = []
        var modelNameSet: Set<String> = []

        for model in self.placementSettings.recentlyPlaced.reversed() {
            if !modelNameSet.contains(model.name) {
                recentsUniqueOrderedArray.append(model)
                modelNameSet.insert(model.name)
            }
        }

        return recentsUniqueOrderedArray
    }
}

// one horizontalGrid
struct HorizontalGrid: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool
    
    private let gridItemLayout = [GridItem(.fixed(150))]
    var title: String
    var modelLibrary: [Model]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Separator()
            
            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    
                    ForEach(0..<modelLibrary.count){ index in
                        let modelAtIndex = modelLibrary[index]
                        
                        ItemButton(model: modelAtIndex){
                            self.loadIfNotLoaded(model: modelAtIndex)
                        
                            self.placementSettings.selectedModel = modelAtIndex
                            self.placementSettings.selectedModelID = modelAtIndex.getModelUID()
                            print("DEBUG::BrowseView: selected \(modelAtIndex.name) for placement.")
                            self.showBrowse = false

                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
            }
        }
        
    }
    
    private func loadIfNotLoaded(model: Model){
        if ModelLibrary.loadedModels[model.getModelUID()] == nil{
            ModelLibrary().loadModelToClone(for: model)
            
            for childModel in model.childs {
                if ModelLibrary.loadedModels[childModel.getModelUID()] == nil {
                    ModelLibrary().loadModelToClone(for: childModel)
                }
            }
        }
    }
}

struct ItemButton: View {
    
    let model: Model
    
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(uiImage: self.model.thumbnail)
                .resizable()
                .frame(height: 150)
                .aspectRatio(1/1, contentMode: .fit)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(8.0)
        }
    }
    
    
}

struct Separator: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}
