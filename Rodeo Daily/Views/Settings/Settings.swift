//
//  Settings.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/3/23.
//

import SwiftUI
import WidgetKit

struct Settings: View {
//    @Environment(\.managedObjectContext) private var viewContext

    @AppStorage("favoriteStandingsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteStandingsEvent: StandingsEvents = .aa
    @AppStorage("favoriteResultsEvent", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteResultsEvent: Events.CodingKeys = .bb
    @AppStorage("favoriteAthleteId", store: UserDefaults(suiteName: "group.PaytonSides.RodeoDaily")) var favoriteAthleteId: Int = 0
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Favorite.lastName, ascending: true)],
//        animation: .default)
//    private var favorites: FetchedResults<Favorite>
    
    var body: some View {
        Form {
            Section(header: Text("Favorites"), footer: Text("The selected events will be used to populate the widget data and load in the respective tab when the app opens.")) {
                Picker("Standings Event", selection: $favoriteStandingsEvent) {
                    ForEach(StandingsEvents.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteStandingsEvent) { newValue in
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                Picker("Results Event", selection: $favoriteResultsEvent) {
                    ForEach(Events.CodingKeys.allCases, id: \.self) { event in
                        Text(event.title)
                    }
                }
                .onChange(of: favoriteResultsEvent) { newValue in
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            
//            Section(header: Text("Favorites")) {
//                ForEach(favorites) { favorite in
//                    HStack {
//                        Text("\(favorite.firstName ?? "") \(favorite.lastName ?? "")")
//
//                        Spacer()
//
//                        Button {
//                            deleteFavorite(favorite: favorite)
//                        } label: {
//                            Image(systemName: "star.fill")
//                                .foregroundColor(.rdYellow)
//                        }
//                    }
//                }
//            }
            
//            Section(header: Text("Favorite Widget")) {
//                
//                Picker("Favorite Widget", selection: $favoriteAthleteId) {
//                    ForEach(favorites) { favorite in
//                        Text("\(favorite.firstName ?? "") \(favorite.lastName ?? "")").tag(Int(favorite.id))
//                    }
//                    Text("None").tag(0)
//                }
//                .onChange(of: favoriteAthleteId) { newValue in
//                    favoriteAthleteId = newValue
//                    WidgetCenter.shared.reloadAllTimelines()
//                }
//                
//                
//            }
        }
        .navigationTitle("Settings")
    }
    
//    private func deleteFavorite(favorite: Favorite) {
//        withAnimation {
//            viewContext.delete(favorite)
//            
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
