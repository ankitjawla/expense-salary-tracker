//
//  TransactionsViewModel.swift
//  Expense & Salary Tracker
//

import Foundation
import Observation
import SwiftData

enum TransactionsKindFilter: String, CaseIterable, Identifiable {
    case all
    case income
    case expense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .income: return "Income"
        case .expense: return "Expenses"
        }
    }
}

@Observable
@MainActor
final class TransactionsViewModel {
    let modelContext: ModelContext
    private let calendar = Calendar.current

    var searchText: String = ""
    var kindFilter: TransactionsKindFilter = .all
    var restrictToCurrentMonth: Bool = false
    var selectedIncomeCategory: IncomeCategory?
    var selectedExpenseCategory: ExpenseCategory?

    private(set) var entries: [TransactionEntry] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func reload() throws {
        let descriptor = FetchDescriptor<TransactionEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        entries = try modelContext.fetch(descriptor)
    }

    var filteredEntries: [TransactionEntry] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return entries.filter { entry in
            if !q.isEmpty {
                if !entry.title.localizedStandardContains(q), !entry.notes.localizedStandardContains(q) {
                    return false
                }
            }

            switch kindFilter {
            case .all:
                break
            case .income:
                if entry.kind != .income { return false }
            case .expense:
                if entry.kind != .expense { return false }
            }

            if restrictToCurrentMonth {
                let now = Date()
                if !calendar.isDate(entry.date, inSameMonthAs: now) {
                    return false
                }
            }

            if let selectedIncomeCategory, entry.kind == .income {
                if entry.incomeCategory != selectedIncomeCategory { return false }
            }

            if let selectedExpenseCategory, entry.kind == .expense {
                if entry.expenseCategory != selectedExpenseCategory { return false }
            }

            return true
        }
    }

    func delete(_ entry: TransactionEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
        try reload()
    }
}
