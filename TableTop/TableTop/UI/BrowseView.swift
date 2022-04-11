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
//                    RecentsGrid(showBrowse: $showBrowse)
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
                if let modelsByCategory = models.get(category: category) {
                    HorizontalGrid(showBrowse: $showBrowse, title: category.label, items: modelsByCategory)
                }
            }
        }
    }
}

// TODO: implement recentsGrid beased on user's selection of objects
//struct RecentsGrid: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
//    @Binding var showBrowse: Bool
//
//    var body: some View {
//        if !self.placementSettings.recentlyPlaced.isEmpty {
//            // create a horitzontalGrid for recentlyPlacedbject
//            HorizontalGrid(showBrowse: $showBrowse, title: "Recents", items: getRecentsUniqueOrdered())
//        }
//    }
//
//    func getRecentsUniqueOrdered() -> [Model] {
//        var recentsUniqueOrderedArray: [Model] = []
//        var modelNameSet: Set<String> = []
//
//        for model in self.placementSettings.recentlyPlaced.reversed() {
//            if !modelNameSet.contains(model.name) {
//                recentsUniqueOrderedArray.append(model)
//                modelNameSet.insert(model.name)
//            }
//        }
//
//        return recentsUniqueOrderedArray
//    }
//}

// one horizontalGrid
struct HorizontalGrid: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool
    
    private let gridItemLayout = [GridItem(.fixed(150))]
    var title: String
    var items: [Model]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Separator()
            
            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    ForEach(0..<items.count) {index in
                        let model = items[index]
                        
                        // TODO: implement code for handling user interaction -- load model entity
                        ItemButton(model: model) {
                            // Load model and their children asynchronously
//                            model.asyncLoadModelEntity()
//                            for chd in model.childs {
//                                chd.asyncLoadModelEntity()
//                                    print(chd.name)
//                                }
//                          self.placementSettings.selectedModel = model
                            print("BrowseView: selected \(model.name) for placement.")
                            self.showBrowse = false
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
            }
        }
        
    }
    
}

struct ItemButton: View {
    
    //TODO: update depends on which class we want to implement load model entity function in
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
