import SwiftUI

@main
struct TableTopApp: App {
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    @StateObject var deletionManager = DeletionManager()
    
    var body: some Scene {
        WindowGroup {
            ControlView()
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
                .environmentObject(deletionManager)
        }
    }
}
