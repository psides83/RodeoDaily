//
//  DateExtansions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

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

enum RodeoDateParser {
    static func parse(_ value: String, rejectPlaceholderDates: Bool = true) -> Date? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        if rejectPlaceholderDates, raw.hasPrefix("0001-01-01") {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = validDate(isoFormatter.date(from: raw), rejectPlaceholderDates: rejectPlaceholderDates) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = validDate(isoFormatter.date(from: raw), rejectPlaceholderDates: rejectPlaceholderDates) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        for format in formats {
            formatter.dateFormat = format
            if let date = validDate(formatter.date(from: raw), rejectPlaceholderDates: rejectPlaceholderDates) {
                return date
            }
        }

        return nil
    }

    static func string(from date: Date, format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = .current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private static let formats = [
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm:ss.SSS",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd",
        "MM/d/yyyy"
    ]

    private static func validDate(_ date: Date?, rejectPlaceholderDates: Bool) -> Date? {
        guard let date else { return nil }
        guard rejectPlaceholderDates else { return date }
        return Calendar.current.component(.year, from: date) <= 1900 ? nil : date
    }
}

extension String {
    var rodeoDate: Date? {
        RodeoDateParser.parse(self)
    }
}
