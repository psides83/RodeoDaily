////
////  AthletesViewModel.swift
////  RodeoDaily
////
////  Created by Payton Sides on 9/26/24.
////
//
//import SwiftUI
//import SwiftData
//
//@Observable
//class AthletesViewModel {
//    var modelContext: ModelContext
//    var athletes = [(WidgetAthlete, BioData)]()
//    var searchText: String
//
//    init(modelContext: ModelContext, searchText: String) {
//        self.modelContext = modelContext
//        self.searchText = searchText
//        
//        fetchData()
//    }
//
////    func addSample() {
////        let movie = Movie(title: "Avatar", cast: ["Sam Worthington", "Zoe Saldaña", "Stephen Lang", "Michelle Rodriguez"])
////        modelContext.insert(movie)
////        fetchData()
////    }
//
//    func fetchData() {
//        let predicate = #Predicate<WidgetAthlete> { athlete in
//            athlete.name.localizedStandardContains(searchText)
//        }
//        
//        do {
//            let descriptor = FetchDescriptor<WidgetAthlete>(predicate: predicate)
//            
//            var tempAthletes = try modelContext.fetch(descriptor)
//            
//            tempAthletes.forEach { athlete in
//                let bioModel = BioViewModel()
//                Task {
//                    await bioModel.getBio(for: athlete.athleteId)
//                }
//                
//                athletes.append((athlete, bioModel.bio))
//            }
//        } catch {
//            print("Fetch failed")
//        }
//    }
//}
