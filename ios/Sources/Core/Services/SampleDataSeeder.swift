//
//  SampleDataSeeder.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData

enum SampleDataSeeder {
    static func insertSampleTransactions(into context: ModelContext) throws {
        let calendar = Calendar.current
        let now = Date()

        func monthOffset(_ i: Int) -> Date {
            calendar.date(byAdding: .month, value: -i, to: now) ?? now
        }

        let samples: [TransactionEntry] = [
            TransactionEntry(
                date: monthOffset(0),
                kind: .income,
                title: "Monthly salary",
                notes: "Net pay",
                amount: 4_800,
                incomeCategory: .salary
            ),
            TransactionEntry(
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                kind: .expense,
                title: "Grocery run",
                notes: "Weekend shopping",
                amount: 126.40,
                expenseCategory: .food
            ),
            TransactionEntry(
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                kind: .expense,
                title: "Transit pass",
                amount: 45,
                expenseCategory: .transport
            ),
            TransactionEntry(
                date: monthOffset(1),
                kind: .income,
                title: "Freelance invoice",
                amount: 950,
                incomeCategory: .freelance
            ),
            TransactionEntry(
                date: monthOffset(1),
                kind: .expense,
                title: "Rent",
                amount: 1_650,
                expenseCategory: .housing
            ),
            TransactionEntry(
                date: monthOffset(1),
                kind: .expense,
                title: "Electric bill",
                amount: 92.15,
                expenseCategory: .utilities
            ),
            TransactionEntry(
                date: monthOffset(2),
                kind: .income,
                title: "Monthly salary",
                amount: 4_800,
                incomeCategory: .salary
            ),
            TransactionEntry(
                date: monthOffset(2),
                kind: .expense,
                title: "Concert tickets",
                amount: 180,
                expenseCategory: .entertainment
            ),
            TransactionEntry(
                date: monthOffset(2),
                kind: .expense,
                title: "Pharmacy",
                amount: 34.90,
                expenseCategory: .health
            ),
        ]

        for entry in samples {
            context.insert(entry)
        }

        try context.save()
    }
}
