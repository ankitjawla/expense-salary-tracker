//
//  TransactionFormViewModel.swift
//  Expense & Salary Tracker
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class TransactionFormViewModel {
    var date: Date = .now
    var kind: TransactionKind = .expense
    var title: String = ""

    var notes: String = ""
    var amountText: String = ""
    var incomeCategory: IncomeCategory = .salary
    var expenseCategory: ExpenseCategory = .other
    var paymentMethod: PaymentMethod = .unspecified
    var receiptImageData: Data?

    private var editingEntry: TransactionEntry?

    init(entry: TransactionEntry? = nil) {
        editingEntry = entry
        if let entry {
            date = entry.date
            kind = entry.kind
            title = entry.title
            notes = entry.notes
            amountText = Self.amountDisplayString(entry.amount)
            incomeCategory = entry.incomeCategory ?? .salary
            expenseCategory = entry.expenseCategory ?? .other
            paymentMethod = entry.paymentMethod
            receiptImageData = entry.receiptImageData
        }
    }

    var isEditing: Bool { editingEntry != nil }

    var parsedAmount: Double? {
        MoneyFormatting.parseAmount(from: amountText)
    }

    var isValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }
        guard let amount = parsedAmount, amount > 0 else { return false }
        return true
    }

    func applyQuickParseResult(_ result: QuickTransactionParserResult) {
        title = result.title
        amountText = Self.amountDisplayString(result.amount)
        date = result.date
        kind = result.kind
        applySmartCategoryFromTitle()
    }

    func applySmartCategoryFromTitle() {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        switch kind {
        case .expense:
            if let s = CategorySuggestionService.suggestExpenseCategory(for: t) {
                expenseCategory = s
            }
        case .income:
            if let s = CategorySuggestionService.suggestIncomeCategory(for: t) {
                incomeCategory = s
            }
        }
    }

    @discardableResult
    func save(using modelContext: ModelContext) throws -> TransactionEntry {
        guard let amount = parsedAmount, amount > 0 else {
            throw FormError.invalidAmount
        }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw FormError.invalidTitle
        }

        if let editingEntry {
            editingEntry.date = date
            editingEntry.kind = kind
            editingEntry.title = trimmedTitle
            editingEntry.notes = notes
            editingEntry.amount = amount
            editingEntry.paymentMethod = paymentMethod
            editingEntry.receiptImageData = receiptImageData
            switch kind {
            case .income:
                editingEntry.incomeCategory = incomeCategory
                editingEntry.expenseCategoryRaw = nil
            case .expense:
                editingEntry.expenseCategory = expenseCategory
                editingEntry.incomeCategoryRaw = nil
            }
            try modelContext.save()
            return editingEntry
        }

        let entry = TransactionEntry(
            date: date,
            kind: kind,
            title: trimmedTitle,
            notes: notes,
            amount: amount,
            incomeCategory: kind == .income ? incomeCategory : nil,
            expenseCategory: kind == .expense ? expenseCategory : nil,
            paymentMethod: paymentMethod,
            receiptImageData: receiptImageData
        )
        modelContext.insert(entry)
        try modelContext.save()
        return entry
    }

    func resetForNewEntry() {
        editingEntry = nil
        date = .now
        kind = .expense
        title = ""
        notes = ""
        amountText = ""
        incomeCategory = .salary
        expenseCategory = .other
        paymentMethod = .unspecified
        receiptImageData = nil
    }

    enum FormError: LocalizedError {
        case invalidAmount
        case invalidTitle

        var errorDescription: String? {
            switch self {
            case .invalidAmount: return "Enter a valid amount greater than zero."
            case .invalidTitle: return "Enter a title for this entry."
            }
        }
    }

    private static func amountDisplayString(_ value: Double) -> String {
        value.formatted(.number.locale(.current).precision(.fractionLength(0...2)))
    }
}
