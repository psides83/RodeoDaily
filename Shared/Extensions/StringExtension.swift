//
//  StringExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

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
    
    var eventDisplay: String {
        switch self {
        case "BB": return "Bareback"
        case "SW": return "Steer Wrestling"
        case "TR": return "Team Roping"
        case "SB": return "Saddle Bronc"
        case "TD": return "Tie-Down Roping"
        case "BR": return "Bull Riding"
        case "SR": return "Steer Roping"
        default: return ""
        }
    }
    
    var eventShort: String {
        switch self.trimmingCharacters(in: .whitespaces) {
        case "Tie-down Roping": return "TD Roping"
        case "Team Roping (Headers)": return "TR Heading"
        case "Team Roping (Heelers)": return "TR Heeling"
        default: return self
        }
    }
}
