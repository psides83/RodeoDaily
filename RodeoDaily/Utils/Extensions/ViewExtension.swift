//
//  ViewExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

// MARK: - View
extension View {
#if os(iOS)
    func safeArea() -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else{return .zero}
        
        guard let safeArea = window.windows.first?.safeAreaInsets else{return .zero}
        
        return safeArea
    }
#endif
    
#if os(iOS)
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
#endif
    
    
    @ViewBuilder
    func offset(coordinateSpcae: CoordinateSpace, completion: @escaping (CGFloat) -> ()) -> some View {
        self.overlay {
            GeometryReader { proxy in
                let minY = proxy.frame(in: coordinateSpcae).minY
                Color.clear.preference(key: OffsetKey.self, value: minY)
                    .onPreferenceChange(OffsetKey.self) { value in
                        completion(value)
                    }
            }
        }
    }
    
    @ViewBuilder
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
#if os(iOS)
    @available(iOS 14, *)
    func navigationBarTitleColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
#endif
}
