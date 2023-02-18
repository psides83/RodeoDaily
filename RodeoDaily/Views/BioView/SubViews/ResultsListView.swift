//
//  ResultsListView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct ResultsListView: View {
    
    @ObservedObject var bioApi = BioApi()
    
    let bio: BioData
    let event: String
    let seasons: [String]
    
    @State private var selectedSeason = Date().yearString
    @State private var sortResultsBy: BioResult.SortingKeyPath = .rodeoDate
//    @State private var searchText = ""
    @StateObject var search = DebouncedObservedObject(wrappedValue: SearchModel(), delay: 0.5)

    @Binding var showSearchBar: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            List(content: listSection)
                .listStyle(.plain)
                .padding(.top, 50)
            
            VStack {
                HStack(alignment: .center) {
                    HStack(spacing: 30) {
                        SortMenuView { keyPath in
                            sortResultsBy = keyPath
                        }
                        
                        SeasonFilterView(seasons: seasons, selectedSeason: $selectedSeason)
                    }
                    
                    ExpandingSearchBar(
                        showing: $showSearchBar,
                        text: $search.text
                    )
                }
                .frame(height: 50)
                .padding(.horizontal, 20)
                .background(Color.secondarySystemGroupedBackground.shadow(radius: 2))
                
                Spacer()
            }
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    var results: [BioResult] {
        bio.results(
            filteredBy: selectedSeason.int,
            filteredBy: event,
            searchText: search.text,
            sortedBy: sortResultsBy)
    }
    
    // MARK: - View Methods
    func listSection() -> some View {
        Section(header: header, footer: BannerAd().frame(height: 50)) {
            ForEach(results, id: \.rodeoResultId) { result in
                BioResultCellView(result: result)
                    .listRowBackground(Color.appBg)
            }
        }
    }
    
    // MARK: - Computed Property Views
    var header: some View {
        var resultType = ""
        if event == "BR" || event == "SB" || event == "BB" {
            resultType = NSLocalizedString("Score", comment: "")
        } else { resultType = NSLocalizedString("Time", comment: "") }
        
        return HStack {
            Text("Place")
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Text(resultType)
                .frame(width: 60, alignment: .center)
            
            Spacer()
            
            Text("Earnings")
                .frame(width: 100, alignment: .trailing)
        }
    }
}

struct ResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BioView(athleteId: 59836, event: .hd)
        }
    }
}
