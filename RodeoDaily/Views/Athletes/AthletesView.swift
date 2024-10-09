//
//  AthletesView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/24/24.
//

import SwiftData
import SwiftUI

struct AthletesView: View {
    @Environment(\.modelContext) var modelContext
    
    @State var searchText: String
    
    @State var athletes: [TempAthlete] = []
    
    @Query var widgetAthletes: [WidgetAthlete]
    
    init(searchText: String = "") {
        self.searchText = searchText
        
        //        _widgetAthletes = Query(filter: #Predicate { athlete in
        //            if searchText.isEmpty {
        //                true
        //            } else {
        //                athlete.name.localizedStandardContains(searchText)
        //            }
        //        })
    }
    
    var body: some View {
        ScrollView {
            Text("Favorite Athletes")
                .foregroundColor(.appSecondary)
                .font(.title)
                .fontWeight(.bold)
                .hSpacing(.leading)
            
            if widgetAthletes.isEmpty {
                ContentUnavailableView {
                    VStack {
                        Text("No Athletes")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPrimary)
                        
                        Image.cowboy
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 72, height:  72)
                            .foregroundStyle(Color.appPrimary)
                        
                    }
                } description: {
                    Text("Add athletes to favorites fromt he settings tab. These athletes will be available to add widgets to you home screen.")
                }
            } else {
                ForEach(widgetAthletes.indices, id: \.self) { index in
                    let athlete = widgetAthletes[index]
                    
                    if (index % 2) == 0 && index != 0 {
                        VStack {
                            BannerAd()
                                .frame(height: 340)
                        }
                    }
                    
                    //                    Text(athlete.name)
                    //                        .font(.headline)
                    //                        .fontWeight(.semibold)
                    //                        .foregroundStyle(Color.appPrimary)
                    
                    NavigationLink {
                        BioView(athleteId: athlete.athleteId)
                    } label: {
                        //                    DisclosureGroup {
                        AthleteCellView(athlete: athlete)
                            .padding(.bottom, 10)
                        //                    } label: {
                        //                        Text(athlete.athlete.name)
                        //                            .foregroundColor(.white)
                        //                            .font(.system(size: 24, weight: .bold))
                        //                            .fontWeight(.semibold)
                        //                    }
                        
                    }
                }
            }
            
            BannerAd()
                .frame(height: 400)
        }
        .onAppear(perform: setTempAthletes)
    }
    
    var filtereredAthletes: [TempAthlete] {
        athletes.filter { athlete in
            if searchText.isEmpty {
                return true
            } else {
                return athlete.athlete.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func setTempAthletes() {
        athletes = widgetAthletes.map { athlete in
            let bioModel = BioViewModel()
            bioModel.selectedEvent = athlete.event
            
            var tempAthlete = TempAthlete(athlete: athlete, ranking: "", results: [])
            
            Task {
                await bioModel.getBio(for: athlete.athleteId)
                
                print(bioModel.seasonRanking())
                tempAthlete.ranking = bioModel.seasonRanking()
                tempAthlete.results = bioModel.bio.results.filter({ $0.eventType == bioModel.selectedEvent }).sorted(by: { $0.endDate > $1.endDate }).prefix(4)
            }
            
            return tempAthlete
        }
    }
}

#Preview {
    AthletesView()
}

struct TempAthlete: Identifiable {
    let athlete: WidgetAthlete
    var ranking: String
    var results: ArraySlice<BioResult>
    
    var id: UUID { athlete.id }
}
