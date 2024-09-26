//
//  Rodeo_DailyApp.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/1/23.
//

import SwiftData
import SwiftUI

@main
struct RodeoDailyApp: App {
//    let persistenceController = PersistenceController.shared
    
    @StateObject var attHandler = ATTHandler()
    
    @AppStorage("needsATTRequest") var needsATTRequest = true

    var body: some Scene {
        WindowGroup {
            Group {
                if attHandler.status == .notDetermined && needsATTRequest {
                    ATTRequestView()
                } else {
                    ContentView()
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .onAppear(perform: attHandler.checkATTStatus)
        }
        .modelContainer(for: WidgetAthlete.self)
    }
}
