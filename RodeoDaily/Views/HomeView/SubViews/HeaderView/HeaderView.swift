//
//  HeaderView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/16/22.
//

import SwiftUI

extension HomeView {
    
    // MARK: - Header View
    @ViewBuilder
    func HeaderView(_ safeAreaTop: CGFloat) -> some View {
        // Reduced Header Height will 80
        let progress = -(offSetY / 80) > 1 ? -1 : (offSetY > 0 ? 0 : (offSetY / 80))
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                SearchBar(progress: progress)
                
                HeaderLogo
            }
            
            HStack(spacing: 0) {
                CustomButton(symbolImage: .standings, title: NSLocalizedString("Standings", comment: "")) {
                    selectedTab = .standings
                }
                
                CustomButton(symbolImage: .results, title: NSLocalizedString("Results", comment: "")) {
                    selectedTab = .results
                }
                
                CustomButton(symbolImage: .settings, title: NSLocalizedString("Settings", comment: "")) {
                    navigatedToSettings = true
                }
            }
            .navigationDestination(isPresented: $navigatedToSettings) {
                SettingsView()
            }
            // Shrinking Horizontal
            .padding(.horizontal, -progress * 50)
            .padding(.top, 10)
            // MARK: Moving Up When Scolling Started
            .offset(y: progress * 65)
            .opacity(isShowingSearchBar ? 0 : 1)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    searchFieldFocused = false
                } label: {
                    Text("Cancel")
                        .foregroundColor(.appSecondary)
                }
            }
        }
        // MARK: Displaying Search Button
        .overlay(alignment: .topLeading, content: {
            Button {
                isShowingSearchBar = true
            } label: {
                Image.search
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .offset(x: 13, y: 10)
            .opacity(isShowingSearchBar ? 0 : -progress)
        })
        .animation(.easeInOut(duration: 0.2), value: isShowingSearchBar)
        .padding([.horizontal, .bottom], 15)
        .padding(.top, safeAreaTop)
        .background {
            Rectangle()
                .fill(Color.appPrimary)
                .padding(.bottom, -progress * 85)
        }
        .environment(\.colorScheme, .light)
    }
    
    // MARK: - Header Logo
    var HeaderLogo: some View {
        Logo(size: 0.5)
            .padding(.vertical, -24)
            .padding(.horizontal, -4)
            .padding(.trailing, 4)
            .opacity(isShowingSearchBar ? 0 : 1)
            .overlay {
                if isShowingSearchBar {
                    // MARK: Displaying XMark Button
                    Button {
                        isShowingSearchBar = false
                        searchFieldFocused = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
    }
}
