//
//  SearchBarView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/16/22.
//

import SwiftUI

extension HomeView {
    // MARK: - SearchBar
    func SearchBar(progress: CGFloat) -> some View {
        HStack(spacing: 8) {
            Image.search
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            TextField("Search", text: $searchText)
                .tint(.white)
                .foregroundColor(.white)
                .focused($searchFieldFocused)
                .submitLabel(.search)
                .onSubmit {
                    if selectedTab == .results {
                        Task {
                            await rodeosApi.searchRodeos(for: resultsEvent, by: searchText, in: dateParams) {
                                rodeosApi.endLoading()
                            }
                        }
                    }
                }
            
            Button {
                clearSearch()
                if selectedTab ==  .results {
                    Task {
                        await rodeosApi.loadRodeos(event: resultsEvent, index: index, searchText: "", dateParams: dateParams) {
                            rodeosApi.endLoading()
                        }
                    }
                }
            } label: {
                Image.clearField
                    .foregroundColor(.appBg)
                    .opacity(searchText.isEmpty ? 0 : 0.6)
                    .disabled(searchText.isEmpty)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 13)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black.opacity(0.15))
        }
        .opacity(isShowingSearchBar ? 1 : 1 + progress)
    }
}
