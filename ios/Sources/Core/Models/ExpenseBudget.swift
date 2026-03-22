//
//  ExpenseBudget.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData

@Model
final class ExpenseBudget {
    @Attribute(.unique) var id: UUID
    var expenseCategoryRaw: String
    var monthlyLimit: Double
    /// Notify when spending reaches this percent of limit (e.g. 80). Use 0 to disable alerts.
    var notifyAtPercent: Double
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        category: ExpenseCategory,
        monthlyLimit: Double,
        notifyAtPercent: Double = 80,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.expenseCategoryRaw = category.rawValue
        self.monthlyLimit = max(0, monthlyLimit)
        self.notifyAtPercent = max(0, min(100, notifyAtPercent))
        self.isEnabled = isEnabled
    }

    var expenseCategory: ExpenseCategory {
        get { ExpenseCategory(rawValue: expenseCategoryRaw) ?? .other }
        set { expenseCategoryRaw = newValue.rawValue }
    }
}
