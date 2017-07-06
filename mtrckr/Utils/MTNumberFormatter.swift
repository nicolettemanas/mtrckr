//
//  MTNumberFormatter.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit

extension NumberFormatter {
    static func currencyStr(withCurrency currency: String, amount: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        return formatter.string(from: NSNumber(value: amount))
    }
}
