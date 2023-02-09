//
//  Extensions.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 4/8/21.
//

import SwiftUI
import Foundation


//MARK: - Double
extension Double {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var currencyABS: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        numberFormatter.maximumFractionDigits = .zero
        return numberFormatter.string(for: self) ?? ""
    }
    
    var string: String {
        return String(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(truncating: NSNumber(value: self))
    }
    
    var shortenedCurrency: String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
                
        if self >= 1000 && self < 999999.999999999999999 {
            return "$\(String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: ""))"
        }
        if self >= 1000000 {
            return "$\(String(format: "%.2fM", self / 1000000).replacingOccurrences(of: ".00", with: ""))"
        }
        
        return numberFormatter.string(for: self) ?? ""
    }
}

//MARK: - CGFloat
extension CGFloat {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var double: Double {
        return Double(self)
    }
    
    var int: Int {
        return Int(self)
    }
    
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
}

//MARK: - String
extension String {
    var double: Double {
        return Double(self) ?? 0.0
    }
    
    var int: Int {
        return Int(self) ?? 0
    }
    
    var monthAbr: String {
        switch (self) {
        case "01": return "Jan"
        case "02": return "Feb"
        case "03": return "Mar"
        case "04": return "Apr"
        case "05": return "May"
        case "06": return "Jun"
        case "07": return "Jul"
        case "08": return "Aug"
        case "09": return "Sep"
        case "10": return "Oct"
        case "11": return "Nov"
        default: return " Dec"
        }
    }
    
    func stringToDate(with format: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        formatter.timeZone = .current
        let string = self
        guard let newDate = formatter.date(from: string) else { return Date() }
        return newDate
    }
    
    var ddMMMyyyy: String {
        let format = DateFormatter()
        format.dateFormat = "dd-MMM-yyyy"
        let date = self.stringToDate(with: "dd-MMM-yyyy hh:mma")
        return format.string(from: date)
    }
    
    var medium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let date = self.stringToDate(with: "yyyy-MM-dd'T'HH:mm:ss")
        return formatter.string(from: date)
    }
    
    var shortenTimestamp: String {
        if self.count >= 11 {
            return String(self.prefix(11))
        } else {
            return self
        }
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let date = self.stringToDate(with: "dd-MMM-yyyy hh:mma")
        return formatter.localizedString(for: date, relativeTo: Date.now)
    }
    
    var crdLogoWhite: String {
        "crd-ios-icon-white"
    }
}

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
}

//MARK: - Int
extension Int16 {
    var int: Int {
        return Int(self)
    }
}

//MARK: - Date
extension Date {
    var yearInt: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: self)) ?? 2022
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: self)
    }
    
    var monthInt: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: self).int
    }
    
    var monthAbriviated: String {
        let format = DateFormatter()
        format.dateFormat = "MMM"
        return format.string(from: self)
    }
    
    var yearAndMonth: String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMM"
        return format.string(from: self)
    }
    
    var ddMMMyyyy: String {
        let format = DateFormatter()
        format.dateFormat = "dd-MMM-yyyy"
        return format.string(from: self)
    }
    
    var timestamp: String {
        let format = DateFormatter()
        format.dateFormat = "dd-MMM-yyyy hh:mma"
        return format.string(from: self)
    }
    
    var id: String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddhhmmss"
        return format.string(from: self)
    }
    
    var medium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }
    
    var dateOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        //        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

//MARK: - Color
extension Color {
    static let rdGreen = Color("rdGreen")
    static let rdYellow = Color("rdYellow")
    static let rdGray = Color("rdGray")
    static let bgcolor = Color("bgcolor")
    static let appPrimary = Color("app-primary")
    static let appSecondary = Color("app-secondary")
    static let appTertiary = Color("app-tertiary")
    static let appBg = Color("app-bg")
    static let appBgOpp = Color("app-bg-opp")
    static let picked = Color.gray.opacity(0.8)
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
}

extension UIColor {
    static let secondary = UIColor(Color.secondary)
    static let mint = UIColor(Color.mint)
    static let picked = UIColor(Color.picked)
}

// MARK: - View
extension View {
    func safeArea() -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else{return .zero}
        
        guard let safeArea = window.windows.first?.safeAreaInsets else{return .zero}
        
        return safeArea
    }
}

// MARK: - Font
extension Text {
    func skiaFont(_ size: CGFloat = 16) -> Text {
        
        self.font(.custom("Skia", size: size))
    }
}

//MARK: - View
#if os(iOS)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
#endif


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
