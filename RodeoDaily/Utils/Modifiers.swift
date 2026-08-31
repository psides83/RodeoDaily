//
//  Modifiers.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/15/22.
//

import SwiftUI

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

extension View {
    func bioHeaderScrollTracking(_ viewModel: BioViewModel) -> some View {
        modifier(BioHeaderScrollTrackingModifier(viewModel: viewModel))
    }
}

private struct BioHeaderScrollTrackingModifier: ViewModifier {
    @ObservedObject var viewModel: BioViewModel
    @State private var initialOffset: CGFloat?

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: BioHeaderScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("BIO_SCROLL_SHARED")).minY
                        )
                }
                .frame(height: 0),
                alignment: .top
            )
            .onPreferenceChange(BioHeaderScrollOffsetPreferenceKey.self) { value in
                if initialOffset == nil {
                    initialOffset = value
                    viewModel.bioScrollOffset = 0
                    viewModel.bioPullDownOffset = 0
                    return
                }

                let baseline = initialOffset ?? value
                let delta = value - baseline
                viewModel.bioScrollOffset = max(-delta, 0)
                viewModel.bioPullDownOffset = max(delta, 0)
            }
    }
}

private struct BioHeaderScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
