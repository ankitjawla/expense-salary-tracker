//
//  MoneyFormatting.swift
//  Expense & Salary Tracker
//

import Foundation

enum MoneyFormatting {
    /// Locale-aware currency string (uses system formatting rules for the given ISO code).
    static func string(amount: Double, currencyCode: String) -> String {
        amount.formatted(.currency(code: currencyCode))
    }

    static func parseAmount(from text: String, locale: Locale = .current) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true

        if let number = formatter.number(from: trimmed) {
            return number.doubleValue
        }

        let sanitized = trimmed
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        return Double(sanitized)
    }
}

enum CurrencyOption: String, CaseIterable, Identifiable, Sendable {
    case usd, eur, gbp, inr, jpy, aud, cad, chf, cny, sgd, aed, nzd, sek, nok, mxn, brl, zar, krw

    var id: String { rawValue.uppercased() }

    var code: String { rawValue.uppercased() }

    var title: String {
        let name = Locale.current.localizedString(forCurrencyCode: code) ?? code
        return "\(code) · \(name)"
    }
}
