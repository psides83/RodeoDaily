//
//  ATTHandler.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/16/23.
//

import AppTrackingTransparency
import SwiftUI

@MainActor
class ATTHandler: ObservableObject {
    
    var status: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }
    
    @AppStorage("needsATTRequest") var needsATTRequest = true

    func checkATTStatus() {
        switch status {
        case .notDetermined:
            needsATTRequest = true
        case .restricted:
            needsATTRequest = false
            AdMobService.shared.configure()
        case .denied:
            needsATTRequest = false
            AdMobService.shared.configure()
        case .authorized:
            needsATTRequest = false
            AdMobService.shared.configure()
        @unknown default:
            needsATTRequest = false
            AdMobService.shared.configure()
        }
    }
    
    func requestTracking() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    break
                case .restricted, .denied, .authorized:
                    Task { @MainActor in
                        self.needsATTRequest = false
                        AdMobService.shared.configure()
                    }
                @unknown default:
                    Task { @MainActor in
                        self.needsATTRequest = false
                        AdMobService.shared.configure()
                    }
                }
            }
        }
    }
}
