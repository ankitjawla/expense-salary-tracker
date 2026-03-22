//
//  CSVExportService.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData

enum CSVExportService {
    static func buildCSV(modelContext: ModelContext, currencyCode: String) throws -> String {
        let descriptor = FetchDescriptor<TransactionEntry>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        let rows = try modelContext.fetch(descriptor)

        var lines: [String] = [
            "date,kind,title,amount,currency,income_category,expense_category,payment_method,notes",
        ]
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]

        for r in rows {
            let inc = r.incomeCategory?.title ?? ""
            let exp = r.expenseCategory?.title ?? ""
            let pay = r.paymentMethod.title
            let safeNotes = r.notes.replacingOccurrences(of: "\"", with: "'")
            let line = [
                iso.string(from: r.date),
                r.kind.rawValue,
                escape(r.title),
                String(r.amount),
                currencyCode,
                escape(inc),
                escape(exp),
                escape(pay),
                escape(safeNotes),
            ].joined(separator: ",")
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }

    private static func escape(_ s: String) -> String {
        if s.contains(",") || s.contains("\n") {
            return "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return s
    }
}
