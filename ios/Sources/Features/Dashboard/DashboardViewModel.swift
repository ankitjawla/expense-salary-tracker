//
//  DashboardViewModel.swift
//  Expense & Salary Tracker
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class DashboardViewModel {
    let modelContext: ModelContext
    private let calendar = Calendar.current

    var referenceMonth: Date = .now
    var monthIncome: Double = 0
    var monthExpense: Double = 0
    var savings: Double = 0
    var priorMonthIncome: Double = 0
    var priorMonthExpense: Double = 0
    var recentTransactions: [TransactionEntry] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var monthTitle: String {
        MonthFormatting.longMonthYear(referenceMonth)
    }

    func reload() throws {
        let start = calendar.startOfMonth(for: referenceMonth)
        let end = calendar.endOfMonth(for: referenceMonth)

        let predicate = #Predicate<TransactionEntry> { entry in
            entry.date >= start && entry.date <= end
        }
        let monthDescriptor = FetchDescriptor<TransactionEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let monthEntries = try modelContext.fetch(monthDescriptor)

        var income = 0.0
        var expense = 0.0
        for entry in monthEntries {
            switch entry.kind {
            case .income: income += entry.amount
            case .expense: expense += entry.amount
            }
        }
        monthIncome = income
        monthExpense = expense
        savings = income - expense

        if let prevStart = calendar.date(byAdding: .month, value: -1, to: start) {
            let prevEnd = calendar.endOfMonth(for: prevStart)
            let prevPredicate = #Predicate<TransactionEntry> { entry in
                entry.date >= prevStart && entry.date <= prevEnd
            }
            let prevDesc = FetchDescriptor<TransactionEntry>(predicate: prevPredicate)
            let prevEntries = try modelContext.fetch(prevDesc)
            var pi = 0.0
            var pe = 0.0
            for entry in prevEntries {
                switch entry.kind {
                case .income: pi += entry.amount
                case .expense: pe += entry.amount
                }
            }
            priorMonthIncome = pi
            priorMonthExpense = pe
        } else {
            priorMonthIncome = 0
            priorMonthExpense = 0
        }

        let allDescriptor = FetchDescriptor<TransactionEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let all = try modelContext.fetch(allDescriptor)
        recentTransactions = Array(all.prefix(6))
    }

    func shiftMonth(by delta: Int) {
        if let d = calendar.date(byAdding: .month, value: delta, to: calendar.startOfMonth(for: referenceMonth)) {
            referenceMonth = d
        }
    }
}
