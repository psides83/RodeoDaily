//
//  BioView.swift
//  Rodeo Daily
//
//  Created by Payton Sides on 2/10/23.
//

import SwiftUI
import WidgetKit

struct BioView: View {
    //MARK: - Properties
    @Environment(\.calendar) var calendar
    
    @StateObject var viewModel = BioViewModel()
    
    let athleteId: Int
    
    // MARK: - View Body
    var body: some View {
        Group {
            if viewModel.loading {
                LogoLoader()
                    .offset(y: 150)
            } else {
                VStack(spacing: 0) {
                    if !viewModel.showSearchBar {
                        BioHeaderView(viewModel: viewModel)
                            .scaleEffect(x: 1, y: viewModel.showSearchBar ? 0 : 1, anchor: .top)
                            .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                    }
                    
                    switch viewModel.infoType {
                    case .bio:
                        HtmlView(htmlContent: viewModel.bio.biographyText)
                        BannerAd()
                            .frame(height: 200)
                    case .results:
                        if viewModel.selectedEvent != nil  {
                            ResultsListView(viewModel: viewModel)
                        } else {
                            ContentUnavailableView {
                                Label("No Event Selected", systemImage: "list.number")
                            } description: {
                                Text("Select an a event in the top right corner to view \(viewModel.bio.name)'s rodeo results.")
                            }
                        }
                    case .career:
                        if viewModel.selectedEvent != nil {
                            
                            CareerListView(viewModel: viewModel)
                        } else {
                            ContentUnavailableView {
                                Label("No Event Selected", systemImage: "list.number")
                            } description: {
                                Text("Select an a event in the top right corner to view \(viewModel.bio.name)'s rodeo career rankings.")
                            }
                        }
                    case .highlights:
                        VideoHighlightsView(viewModel: viewModel)
                    }
                }
                .background(Color.appBg)
                .navigationTitle(viewModel.bio.name)
                .navigationBarTitleColor(.appSecondary)
                //                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color.rdGreen, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarRole(.navigationStack)
                .toolbar {
                    //                    ToolbarItem(placement: .navigationBarTrailing) { favoriteButton() }
                    EventFilterView(
                        events: viewModel.bio.events,
                        selectedEvent: $viewModel.selectedEvent
                    )
                    .tint(.appSecondary)
                }
            }
        }
        .task {
            print(athleteId)
            if athleteId != 0 {
                await viewModel.getBio(for: athleteId)
            }
        }
    }
}

// MARK: - Preview
struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BioView(athleteId: 72983)
                .tint(.appSecondary)
        }
    }
}
