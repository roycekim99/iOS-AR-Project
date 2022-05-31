import SwiftUI

enum Setting {
    case peopleOcclusion
    case objectOcclusion
    case lidarDebug
    case physics
    
    var label: String {
        get {
            switch self {
            case .peopleOcclusion, .objectOcclusion:
                return "Occlusion"
            case .lidarDebug:
                return "LiDAR"
            case .physics:
                return "Physics"
            }
        }
    }
    
    var systemIconName: String {
        get {
            switch self {
            case .peopleOcclusion:
                return "person"
            case .objectOcclusion:
                return  "cube.box.fill"
            case .lidarDebug:
                return "light.min"
            case .physics:
                return "burst.fill"
            }
        }
    }
}

// State variables for setting toggles
class SessionSettings: ObservableObject {
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isPhysicsEnabled: Bool = false
}


struct SettingsView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationView {
            SettingsGrid()
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                    self.showSettings.toggle()
                }) {
                    Text("Done").bold()
                })
        }
    }
}

struct SettingsGrid: View {
    @EnvironmentObject var sessionSettings: SessionSettings
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]
    
    var body: some View {
        ScrollView {
            
            LazyVGrid(columns: gridItemLayout, spacing: 25) {
                
                SettingToggleButton(setting: .peopleOcclusion, isOn: $sessionSettings.isPeopleOcclusionEnabled)
                
                SettingToggleButton(setting: .objectOcclusion, isOn: $sessionSettings.isObjectOcclusionEnabled)
                
                SettingToggleButton(setting: .lidarDebug, isOn: $sessionSettings.isLidarDebugEnabled)
                                
                PhysicsButton(setting: .physics, isOn: $sessionSettings.isPhysicsEnabled)
            }
        }
        .padding(.top, 35)
    }
}

// Set up functions for buttons
struct SettingToggleButton: View {
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            print("\(#file) - \(setting): \(self.isOn)")
        }) {
            VStack {
                
                Image(systemName: setting.systemIconName)
                    .font(.system(size: 35))
                    .foregroundColor(self.isOn ? .green : Color(UIColor.secondaryLabel))
                    .buttonStyle(PlainButtonStyle())
                
                Text(setting.label)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundColor(self.isOn ? Color(UIColor.label) : Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20.0)
    }
}

struct PhysicsButton: View {
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            CustomARView.Holder.physicsEnabled.toggle()
            print("\(#file) - \(setting): \(self.isOn)")
            ModelManager.getInstance().resetAll()
        }) {
            VStack {
                
                Image(systemName: setting.systemIconName)
                    .font(.system(size: 35))
                    .foregroundColor(self.isOn ? .green : Color(UIColor.secondaryLabel))
                    .buttonStyle(PlainButtonStyle())
                
                Text(setting.label)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundColor(self.isOn ? Color(UIColor.label) : Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20.0)
    }
}
