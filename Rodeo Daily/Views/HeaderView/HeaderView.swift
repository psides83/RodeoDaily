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
                CustomButton(symbolImage: "list.number", title: "Standings") {
                    selectedTab = .standings
                }
                
                CustomButton(symbolImage: "dollarsign.square", title: "Results") {
                    selectedTab = .results
                }
                
//                CustomButton(symbolImage: "person.text.rectangle", title: "Settings") {}
                
                NavigationLink {
                    Settings()
                } label: {
                    VStack(spacing: 8) {
                        
                        Image(systemName: "slider.horizontal.3")
                            .fontWeight(.semibold)
                            .foregroundColor(.rdGreen)
                            .frame(width: 35, height: 35)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.white)
                            }
                        
                        Text("Settings")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(1 + progress)
                    // MARK: Display Alternative Icon
                    .overlay {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .opacity(-progress)
                            .offset(y: -10)
                    }
                }
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
                        .foregroundColor(.rdGreen)
                }
            }
        }
        // MARK: Displaying Search Button
        .overlay(alignment: .topLeading, content: {
            Button {
                isShowingSearchBar = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .offset(x: 13, y: 10)
            .opacity(isShowingSearchBar ? 0 : -progress)
        })
        .animation(.easeInOut(duration: 0.2), value: isShowingSearchBar)
        .environment(\.colorScheme, .dark)
        .padding([.horizontal, .bottom], 15)
        .padding(.top, safeAreaTop)
        .background {
            Rectangle()
                .fill(Color.rdGreen)
                .padding(.bottom, -progress * 85)
        }
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
