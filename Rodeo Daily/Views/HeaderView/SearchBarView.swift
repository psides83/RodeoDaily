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
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            TextField("Search", text: $searchText)
                .tint(.white)
                .focused($searchFieldFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await rodeosApi.searchRodeos(for: resultsEvent, by: searchText, in: dateParams) {
                            rodeosApi.endLoading()
                        }
                    }
                }
            
            Button {
                clearSearch()
                Task {
                    await rodeosApi.loadRodeos(event: resultsEvent, index: index, searchText: "", dateParams: dateParams) {
                        rodeosApi.endLoading()
                    }
                }
            } label: {
                Image(systemName: "delete.left.fill")
                    .accentColor(.white)
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
