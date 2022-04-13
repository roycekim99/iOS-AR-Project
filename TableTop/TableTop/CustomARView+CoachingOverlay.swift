/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for conforming to the ARCoachingOverlayViewDelegate protocol.
*/

/*
import UIKit
import ARKit

extension CustomARView: ARCoachingOverlayViewDelegate {
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        messageLabel?.ignoreMessages = true
        messageLabel?.isHidden = true
//        restartButton.isHidden = true
    }

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        messageLabel?.ignoreMessages = false
//        restartButton.isHidden = false
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        resetTracking()
    }

    func setupCoachingOverlay() {
        // Set up coaching view
        coachingOverlay.session = self.session
        coachingOverlay.delegate = self
        coachingOverlay.goal = .tracking
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: self.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
    }
}
*/
