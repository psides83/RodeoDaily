//
//  HomeView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/16/22.
//

import SwiftUI

extension HomeView {
    //MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let safeAreaTop = proxy.safeAreaInsets.top
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        HeaderView(safeAreaTop)
                            .offset(y: -offSetY)
                            .zIndex(1)
                        
                        Main(safeAreaTop: safeAreaTop)
                    }
                    .offset(coordinateSpcae: .named(coordinateSpace)) { offset in
                        offSetY = offset
                        isShowingSearchBar = (-offset > 80) && isShowingSearchBar
                    }
                }
                .background(Color.appBg)
                .coordinateSpace(name: coordinateSpace)
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
}
