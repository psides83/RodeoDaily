//
//  ViewExtensions.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import Foundation
import SwiftUI

/// Offset View Extension
extension View {
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
}
