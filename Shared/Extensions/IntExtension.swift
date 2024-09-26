//
//  IntExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

//MARK: - Int
extension Int {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var string: String {
        return String(self)
    }
    
    var double: Double {
        return Double(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(truncating: NSNumber(value: self))
    }
    
    var toRGBDouble: Double {
        let conversion = Double(self) / 255.0
        return conversion
    }
    
    var word: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(for: self) ?? ""
    }
}

//MARK: - Int
extension Int16 {
    var int: Int {
        return Int(self)
    }
}
