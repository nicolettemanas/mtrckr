//
//  Date+Converter.swift
//  mtrckr
//
//  Created by User on 7/27/17.
//

import UIKit

/// :nodoc:
extension Date {
    func toUTC() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcString = dateFormatter.string(from: self)
        return dateFormatter.date(from: utcString)!
    }

    func toLocal() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        let localString = dateFormatter.string(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: localString)!
    }
}
