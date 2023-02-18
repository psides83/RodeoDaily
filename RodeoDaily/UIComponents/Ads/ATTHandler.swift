//
//  ATTHandler.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/16/23.
//

import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

class ATTHandler: ObservableObject {
    
    let status = ATTrackingManager.trackingAuthorizationStatus
    
    @AppStorage("needsATTRequest") var needsATTRequest = true

    func checkATTStatus() {
        switch status {
        case .notDetermined:
            needsATTRequest = true
            break
        case .restricted:
            print("tracking restricted")
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
            [ "2077ef9a63d2b398840261c8221a0c9b" ]
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "2077ef9a63d2b398840261c8221a0c9b" ]
            GADMobileAds.sharedInstance().disableSDKCrashReporting()
            GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)
            break
        case .denied:
            print("tracking denied")
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
                [ "2077ef9a63d2b398840261c8221a0c9b" ]
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "2077ef9a63d2b398840261c8221a0c9b" ]
            GADMobileAds.sharedInstance().disableSDKCrashReporting()
            GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)
            break
        case .authorized:
            print("tracking authorized")
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "2077ef9a63d2b398840261c8221a0c9b" ]
            break
        @unknown default:
            break
        }
    }
    
    func requestTracking() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    break
                case .restricted:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    GADMobileAds.sharedInstance().disableSDKCrashReporting()
                    GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)
                    DispatchQueue.main.async {
                        self.needsATTRequest = false
                    }
                    break
                case .denied:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    GADMobileAds.sharedInstance().disableSDKCrashReporting()
                    GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)
                    DispatchQueue.main.async {
                        self.needsATTRequest = false
                    }
                    break
                case .authorized:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    DispatchQueue.main.async {
                        self.needsATTRequest = false
                    }
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
