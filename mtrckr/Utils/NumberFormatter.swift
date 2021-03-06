//
//  MTNumberFormatter.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit

extension NumberFormatter {

    /// Returns a string currency version of a given `Double`
    ///
    /// - Parameters:
    ///   - currency: The currency to be displayed
    ///   - amount: The amount to be converted to currency
    /// - Returns: The currency-formatted string
    static func currencyStr(withCurrency currency: String, amount: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        return formatter.string(from: NSNumber(value: amount))
    }

    /// Returns a short string currency version of a given `Double`.
    /// Eg.: 1.2K, 34M, 23.3K
    ///
    /// - Parameters:
    ///   - currency: The currency to be displayed
    ///   - amount: The amount to be converted to currency
    /// - Returns: The currency-formatted string
    static func currencyKString(withCurrency currency: String, amount: Double) -> String? {
        if abs(amount) >= 1000 {
            if abs(amount) >= 1000000 {
                let dec = amount/1000000
                if amount.truncatingRemainder(dividingBy: 1000000) == 0 {
                    return String(format: "%@%.0fM", currency, dec)
                }
                return String(format: "%@%.2fM", currency, dec)
            }
            let dec = amount/1000
            if amount.truncatingRemainder(dividingBy: 1000) == 0 { return String(format: "%@%.0fK", currency, dec) }
            return String(format: "%@%.2fK", currency, dec)
        }
        return NumberFormatter.currencyStr(withCurrency:currency, amount:ceil(amount))
    }
}
