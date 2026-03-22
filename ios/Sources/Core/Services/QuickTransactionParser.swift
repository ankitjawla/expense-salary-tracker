//
//  QuickTransactionParser.swift
//  Expense & Salary Tracker
//

import Foundation

/// Parses short free-text like "Coffee 4.50" or "+120 salary" on-device.
struct QuickTransactionParserResult: Sendable {
    var title: String
    var amount: Double
    var date: Date
    var kind: TransactionKind
}

enum QuickTransactionParser {
    private static let calendar = Calendar.current

    static func parse(_ text: String) -> QuickTransactionParserResult? {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }

        var kind: TransactionKind = .expense
        let lower = t.lowercased()
        if lower.hasPrefix("income ") {
            kind = .income
            t = String(t.dropFirst("income ".count)).trimmingCharacters(in: .whitespaces)
        } else if t.hasPrefix("+") {
            kind = .income
            t = String(t.dropFirst()).trimmingCharacters(in: .whitespaces)
        }

        var date = Date()
        var working = t.lowercased()
        if working.contains("yesterday") {
            if let d = calendar.date(byAdding: .day, value: -1, to: Date()) {
                date = d
            }
            t = t.replacingOccurrences(of: "yesterday", with: " ", options: .caseInsensitive)
            t = t.replacingOccurrences(of: "Yesterday", with: " ")
        }
        working = t.lowercased()
        if working.contains("today") {
            t = t.replacingOccurrences(of: "today", with: " ", options: .caseInsensitive)
            t = t.replacingOccurrences(of: "Today", with: " ")
        }

        let parts = t.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !parts.isEmpty else { return nil }

        var amount: Double?
        var amountIndex: Int?
        for (i, part) in parts.enumerated() {
            let clean = part.replacingOccurrences(of: ",", with: ".")
            if let v = Double(clean), v > 0 {
                amount = v
                amountIndex = i
                break
            }
        }
        guard let amt = amount, let idx = amountIndex else { return nil }

        let titleParts = parts.enumerated().filter { $0.offset != idx }.map(\.element)
        let titleRaw = titleParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        let title = titleRaw.isEmpty ? "Quick entry" : capitalizeFirst(titleRaw)

        return QuickTransactionParserResult(
            title: title,
            amount: amt,
            date: calendar.startOfDay(for: date),
            kind: kind
        )
    }

    private static func capitalizeFirst(_ s: String) -> String {
        guard let first = s.first else { return s }
        return String(first).uppercased() + s.dropFirst()
    }
}
