//
//  Modifiers.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/15/22.
//

import SwiftUI

struct skia: ViewModifier {
    
    static let largeTitle: CGFloat = 36
    static let title2: CGFloat = 28
    static let title3: CGFloat = 24
    static let headline: CGFloat = 20
    static let subheadline: CGFloat = 18
    static let body: CGFloat = 16
    static let callout: CGFloat = 14
    static let caption: CGFloat = 12
    static let caption2: CGFloat = 10
    static let footnote: CGFloat = 8
    
    var size: CGFloat = body
                        
    func body(content: Content) -> some View {
        content
            .font(.custom("Skia", size: size))
    }
}
