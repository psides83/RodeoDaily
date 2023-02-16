//
//  TextExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

// MARK: - Font
extension Text {
    func skiaFont(_ size: CGFloat = 16) -> Text {
        
        self.font(.custom("Skia", size: size))
    }
}
