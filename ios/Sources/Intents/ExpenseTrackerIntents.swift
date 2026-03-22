//
//  ExpenseTrackerIntents.swift
//  Expense & Salary Tracker
//

import AppIntents
import SwiftData

struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log expense"
    static var description = IntentDescription("Adds an expense locally in Expense & Salary Tracker.")

    @Parameter(title: "Title") var title: String
    @Parameter(title: "Amount") var amount: Double

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) expense for \(\.$title)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let ctx = ModelContext(SharedModelStore.shared)
        let entry = TransactionEntry(
            date: .now,
            kind: .expense,
            title: title,
            notes: "",
            amount: amount,
            expenseCategory: CategorySuggestionService.suggestExpenseCategory(for: title) ?? .other
        )
        ctx.insert(entry)
        try ctx.save()
        let code = UserDefaults.standard.string(forKey: "selectedCurrencyCode") ?? "USD"
        TransactionSaveSideEffects.run(modelContext: ctx, currencyCode: code, touchedEntry: entry)
        return .result(dialog: "Logged \(MoneyFormatting.string(amount: amount, currencyCode: code)) for \(title).")
    }
}

struct LogIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log income"
    static var description = IntentDescription("Adds income locally in Expense & Salary Tracker.")

    @Parameter(title: "Title") var title: String
    @Parameter(title: "Amount") var amount: Double

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) income for \(\.$title)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let ctx = ModelContext(SharedModelStore.shared)
        let entry = TransactionEntry(
            date: .now,
            kind: .income,
            title: title,
            notes: "",
            amount: amount,
            incomeCategory: CategorySuggestionService.suggestIncomeCategory(for: title) ?? .salary
        )
        ctx.insert(entry)
        try ctx.save()
        let code = UserDefaults.standard.string(forKey: "selectedCurrencyCode") ?? "USD"
        TransactionSaveSideEffects.run(modelContext: ctx, currencyCode: code, touchedEntry: entry)
        return .result(dialog: "Logged \(MoneyFormatting.string(amount: amount, currencyCode: code)) for \(title).")
    }
}

// Register phrases in the Shortcuts app using Log expense / Log income intents (on-device).
