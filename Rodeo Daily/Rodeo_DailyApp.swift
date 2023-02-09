//
//  Rodeo_DailyApp.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/1/23.
//

import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

@main
struct Rodeo_DailyApp: App {
//    let persistenceController = PersistenceController.shared
    
    let status = ATTrackingManager.trackingAuthorizationStatus
    
    @AppStorage("needsATTRequest") var needsATTRequest = true
    
    init() {
//        GADMobileAds.sharedInstance().start(completionHandler: nil)
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "2077ef9a63d2b398840261c8221a0c9b" ]
//            GADMobileAds.sharedInstance().disableSDKCrashReporting()
//            GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)
//            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
//            UserDefaults.standard.set(0, forKey: "gad_has_consent_for_cookies")
        
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

    var body: some Scene {
        WindowGroup {
            if status == .notDetermined && needsATTRequest {
                ATTRequestView(requestTracking: requestTracking)
            } else {
                ContentView()
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
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
                    needsATTRequest = false
                    break
                case .denied:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    GADMobileAds.sharedInstance().disableSDKCrashReporting()
                    GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)
                    needsATTRequest = false
                    break
                case .authorized:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    needsATTRequest = false
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
