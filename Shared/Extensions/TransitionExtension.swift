//
//  TransitionExtension.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/14/24.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFadeOutRight: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }
}
