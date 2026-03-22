//
//  AnalyticsViewModel.swift
//  Expense & Salary Tracker
//

import Foundation
import Observation
import SwiftData

struct MonthlyCashflow: Identifiable, Sendable {
    let id: String
    let monthStart: Date
    let label: String
    let income: Double
    let expense: Double
}

struct CategoryExpenseSlice: Identifiable, Sendable {
    let id: String
    let title: String
    let amount: Double
}

@Observable
@MainActor
final class AnalyticsViewModel {
    let modelContext: ModelContext
    private let calendar = Calendar.current

    var referenceMonth: Date = .now
    private(set) var allEntries: [TransactionEntry] = []
    private(set) var monthlyBars: [MonthlyCashflow] = []
    private(set) var expenseSlices: [CategoryExpenseSlice] = []
    private(set) var yearToDateIncome: Double = 0
    private(set) var yearToDateExpense: Double = 0

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var monthTitle: String {
        MonthFormatting.longMonthYear(referenceMonth)
    }

    func reload() throws {
        let descriptor = FetchDescriptor<TransactionEntry>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        allEntries = try modelContext.fetch(descriptor)
        monthlyBars = buildMonthlyBars(monthCount: 6)
        expenseSlices = buildExpenseSlices(for: referenceMonth)
        let y = calendar.component(.year, from: Date())
        yearToDateIncome = allEntries.filter { calendar.component(.year, from: $0.date) == y && $0.kind == .income }
            .reduce(0) { $0 + $1.amount }
        yearToDateExpense = allEntries.filter { calendar.component(.year, from: $0.date) == y && $0.kind == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    var yearSummaryTitle: String {
        String(calendar.component(.year, from: Date()))
    }

    func shiftMonth(by delta: Int) {
        if let d = calendar.date(byAdding: .month, value: delta, to: calendar.startOfMonth(for: referenceMonth)) {
            referenceMonth = d
        }
    }

    private func buildMonthlyBars(monthCount: Int) -> [MonthlyCashflow] {
        let endMonth = calendar.startOfMonth(for: Date())
        guard let startMonth = calendar.date(byAdding: .month, value: -(monthCount - 1), to: endMonth) else {
            return []
        }

        var months: [Date] = []
        var cursor = startMonth
        while cursor <= endMonth {
            months.append(cursor)
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }

        return months.map { monthStart in
            let monthEnd = calendar.endOfMonth(for: monthStart)
            let inMonth = allEntries.filter { $0.date >= monthStart && $0.date <= monthEnd }
            var income = 0.0
            var expense = 0.0
            for entry in inMonth {
                switch entry.kind {
                case .income: income += entry.amount
                case .expense: expense += entry.amount
                }
            }
            let id = String(monthStart.timeIntervalSince1970)
            return MonthlyCashflow(
                id: id,
                monthStart: monthStart,
                label: MonthFormatting.shortMonth(monthStart),
                income: income,
                expense: expense
            )
        }
    }

    private func buildExpenseSlices(for month: Date) -> [CategoryExpenseSlice] {
        let start = calendar.startOfMonth(for: month)
        let end = calendar.endOfMonth(for: month)
        let expenses = allEntries.filter { $0.date >= start && $0.date <= end && $0.kind == .expense }

        var totals: [ExpenseCategory: Double] = [:]
        for entry in expenses {
            let category = entry.expenseCategory ?? .other
            totals[category, default: 0] += entry.amount
        }

        return ExpenseCategory.allCases.compactMap { category in
            guard let amount = totals[category], amount > 0 else { return nil }
            return CategoryExpenseSlice(id: category.rawValue, title: category.title, amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }
}
