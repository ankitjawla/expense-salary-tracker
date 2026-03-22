//
//  TransactionSaveSideEffects.swift
//  Expense & Salary Tracker
//

import CoreSpotlight
import SwiftData

/// Local side effects after the ledger changes: Spotlight, Home Screen widget snapshot, budget checks.
enum TransactionSaveSideEffects {
    static func run(modelContext: ModelContext, currencyCode: String, touchedEntry: TransactionEntry?) {
        if let touchedEntry {
            TransactionSpotlightIndexer.index(touchedEntry)
        }
        try? WidgetSnapshotWriter.update(modelContext: modelContext, currencyCode: currencyCode)
        try? BudgetNotificationService.evaluateBudgets(modelContext: modelContext, currencyCode: currencyCode)
    }

    static func fullReindex(modelContext: ModelContext, currencyCode: String) {
        try? TransactionSpotlightIndexer.reindexAll(modelContext: modelContext)
        try? WidgetSnapshotWriter.update(modelContext: modelContext, currencyCode: currencyCode)
    }

    static func afterDelete(modelContext: ModelContext, currencyCode: String, removedId: UUID) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [removedId.uuidString])
        try? WidgetSnapshotWriter.update(modelContext: modelContext, currencyCode: currencyCode)
    }
}
