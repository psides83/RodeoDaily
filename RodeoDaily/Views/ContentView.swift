//
//  ContentView.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/1/23.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .tint(.appSecondary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
