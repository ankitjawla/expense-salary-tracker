//
//  TransactionSpotlightIndexer.swift
//  Expense & Salary Tracker
//

import CoreSpotlight
import Foundation
import SwiftData
import UniformTypeIdentifiers

enum TransactionSpotlightIndexer {
    private static let domain = "com.expensesalarytracker.transaction"

    static func reindexAll(modelContext: ModelContext) throws {
        let entries = try modelContext.fetch(FetchDescriptor<TransactionEntry>())
        var items: [CSSearchableItem] = []
        for entry in entries {
            items.append(searchableItem(for: entry))
        }
        CSSearchableIndex.default().indexSearchableItems(items)
    }

    static func index(_ entry: TransactionEntry) {
        CSSearchableIndex.default().indexSearchableItems([searchableItem(for: entry)])
    }

    static func remove(_ entry: TransactionEntry) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [entry.id.uuidString])
    }

    private static func searchableItem(for entry: TransactionEntry) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: UTType.plainText)
        attributes.title = entry.title
        attributes.contentDescription = "\(entry.kind.title) · \(entry.notes)"
        attributes.keywords = [
            entry.kind.title,
            entry.incomeCategory?.title,
            entry.expenseCategory?.title,
            entry.paymentMethod.title,
        ]
        .compactMap { $0 }

        return CSSearchableItem(
            uniqueIdentifier: entry.id.uuidString,
            domainIdentifier: domain,
            attributeSet: attributes
        )
    }
}
