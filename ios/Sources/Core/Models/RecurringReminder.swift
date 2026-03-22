//
//  RecurringReminder.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData

@Model
final class RecurringReminder {
    @Attribute(.unique) var id: UUID
    var title: String
    var amountHint: Double
    var kindRaw: String
    var expenseCategoryRaw: String?
    var incomeCategoryRaw: String?
    /// Day of month (1–28) for the monthly notification.
    var dayOfMonth: Int
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        title: String,
        amountHint: Double,
        kind: TransactionKind,
        expenseCategory: ExpenseCategory? = nil,
        incomeCategory: IncomeCategory? = nil,
        dayOfMonth: Int,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.amountHint = max(0, amountHint)
        self.kindRaw = kind.rawValue
        self.expenseCategoryRaw = expenseCategory?.rawValue
        self.incomeCategoryRaw = incomeCategory?.rawValue
        self.dayOfMonth = min(28, max(1, dayOfMonth))
        self.isEnabled = isEnabled
    }

    var kind: TransactionKind {
        get { TransactionKind(rawValue: kindRaw) ?? .expense }
        set { kindRaw = newValue.rawValue }
    }

    var notificationRequestIdentifier: String {
        "recurring-\(id.uuidString)"
    }
}
