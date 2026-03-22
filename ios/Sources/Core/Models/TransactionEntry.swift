//
//  TransactionEntry.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData

@Model
final class TransactionEntry {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var date: Date
    var kindRaw: String
    var title: String
    var notes: String
    var amount: Double
    var incomeCategoryRaw: String?
    var expenseCategoryRaw: String?
    var paymentMethodRaw: String = PaymentMethod.unspecified.rawValue
    @Attribute(.externalStorage) var receiptImageData: Data?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        date: Date,
        kind: TransactionKind,
        title: String,
        notes: String = "",
        amount: Double,
        incomeCategory: IncomeCategory? = nil,
        expenseCategory: ExpenseCategory? = nil,
        paymentMethod: PaymentMethod = .unspecified,
        receiptImageData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.date = date
        self.kindRaw = kind.rawValue
        self.title = title
        self.notes = notes
        self.amount = max(0, amount)
        self.incomeCategoryRaw = incomeCategory?.rawValue
        self.expenseCategoryRaw = expenseCategory?.rawValue
        self.paymentMethodRaw = paymentMethod.rawValue
        self.receiptImageData = receiptImageData
    }

    var kind: TransactionKind {
        get { TransactionKind(rawValue: kindRaw) ?? .expense }
        set { kindRaw = newValue.rawValue }
    }

    var incomeCategory: IncomeCategory? {
        get {
            guard let raw = incomeCategoryRaw else { return nil }
            return IncomeCategory(rawValue: raw)
        }
        set { incomeCategoryRaw = newValue?.rawValue }
    }

    var expenseCategory: ExpenseCategory? {
        get {
            guard let raw = expenseCategoryRaw else { return nil }
            return ExpenseCategory(rawValue: raw)
        }
        set { expenseCategoryRaw = newValue?.rawValue }
    }

    var paymentMethod: PaymentMethod {
        get { PaymentMethod(rawValue: paymentMethodRaw) ?? .unspecified }
        set { paymentMethodRaw = newValue.rawValue }
    }
}
