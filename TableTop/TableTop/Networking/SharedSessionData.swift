import Foundation

// Class to hold information about the game session we want to send/receive from server
struct SharedSessionData: Codable {
    var modelUID: String
    var modelName: String
    var positionX: Float
    var positionY: Float
    var positionZ: Float
}
