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
    let preferredInfoTypeRawValue: String?
    let preferredEvent: String?
    private let bioHeaderExpandedHeight: CGFloat = 474
    
    init(
        athleteId: Int,
        preferredInfoTypeRawValue: String? = nil,
        preferredEvent: String? = nil
    ) {
        self.athleteId = athleteId
        self.preferredInfoTypeRawValue = preferredInfoTypeRawValue
        self.preferredEvent = preferredEvent
    }
    
    // MARK: - View Body
    var body: some View {
        Group {
            if viewModel.loading {
                LogoLoader()
                    .offset(y: 150)
            } else {
                ZStack(alignment: .top) {
                    selectedInfoView
                        .id(selectedInfoViewID)

//                    if !viewModel.showSearchBar {
                        BioTelegramHeaderView(viewModel: viewModel)
//                            .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                            .zIndex(1)
//                    }
                }
                .ignoresSafeArea(edges: .top)
                .coordinateSpace(name: "BIO_SCROLL_SHARED")
                .background(Color.appBg)
                .navigationTitle("")
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarRole(.navigationStack)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        EventFilterView(
                            events: viewModel.bio.events,
                            selectedEvent: $viewModel.selectedEvent
                        )
                        .tint(.appSecondary)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        BioFavoriteToolbarButton(viewModel: viewModel, athleteId: athleteId)
                    }
                }
            }
        }
        .task(id: athleteId) {
            print(athleteId)
            if athleteId != 0 {
                await viewModel.getBio(for: athleteId)
                
                if let preferredEvent, viewModel.bio.events.contains(preferredEvent) {
                    print("event: ", preferredEvent)
                    await viewModel.setSelectedEvent(preferredEvent)
                }
                
                if let preferredInfoTypeRawValue,
                   let infoType = BioViewModel.BioInfoType(rawValue: preferredInfoTypeRawValue) {
                    viewModel.infoType = infoType
                }
            }
        }
        .onChange(of: viewModel.infoType) { _, _ in
//            viewModel.bioScrollOffset = 0
//            viewModel.bioPullDownOffset = 0
//            viewModel.bioHasUserScrolled = false
        }
        .onAppear {
            viewModel.bioScrollOffset = 0
            viewModel.bioPullDownOffset = 0
            viewModel.bioHasUserScrolled = false
#if os(iOS)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
            UINavigationBar.appearance().isTranslucent = true
#endif
        }
        .onChange(of: viewModel.loading) { _, isLoading in
            guard isLoading == false else { return }
//            viewModel.bioScrollOffset = 0
//            viewModel.bioPullDownOffset = 0
//            viewModel.bioHasUserScrolled = false
        }
        .onDisappear {
            viewModel.bioScrollOffset = 0
            viewModel.bioPullDownOffset = 0
            viewModel.bioHasUserScrolled = false
        }
    }

    @ViewBuilder
    private var selectedInfoView: some View {
        switch viewModel.infoType {
        case .results:
            if viewModel.selectedEvent != nil  {
                ResultsListView(viewModel: viewModel)
            } else {
                ContentUnavailableView {
                    Label("No Event Selected", systemImage: "list.number")
                } description: {
                    Text("Select an a event in the top right corner to view \(viewModel.bio.name)'s rodeo results.")
                }
                .padding(.top, viewModel.showSearchBar ? 0 : bioHeaderExpandedHeight)
            }
        case .stats:
            if viewModel.selectedEvent != nil  {
                BioStatsView(viewModel: viewModel)
            } else {
                ContentUnavailableView {
                    Label("No Event Selected", systemImage: "list.number")
                } description: {
                    Text("Select an a event in the top right corner to view \(viewModel.bio.name)'s rodeo results.")
                }
                .padding(.top, viewModel.showSearchBar ? 0 : bioHeaderExpandedHeight)
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
                .padding(.top, viewModel.showSearchBar ? 0 : bioHeaderExpandedHeight)
            }
        case .highlights:
            VideoHighlightsView(viewModel: viewModel)
        }
    }

    private var selectedInfoViewID: String {
        [
            viewModel.infoType.rawValue,
            viewModel.selectedEvent ?? "",
            viewModel.selectedSeason,
            viewModel.bio.contestantId.string
        ].joined(separator: "-")
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
