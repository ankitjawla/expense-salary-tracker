//
//  WidgetSnapshotWriter.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData

#if canImport(WidgetKit)
import WidgetKit
#endif

enum WidgetSnapshotWriter {
    private static let key = "month_snapshot_v1"

    static func update(modelContext: ModelContext, currencyCode: String) throws {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.startOfMonth(for: now)
        let end = calendar.endOfMonth(for: now)

        let predicate = #Predicate<TransactionEntry> { entry in
            entry.date >= start && entry.date <= end
        }
        let descriptor = FetchDescriptor<TransactionEntry>(predicate: predicate)
        let monthEntries = try modelContext.fetch(descriptor)

        var income = 0.0
        var expense = 0.0
        for e in monthEntries {
            switch e.kind {
            case .income: income += e.amount
            case .expense: expense += e.amount
            }
        }

        let payload: [String: Any] = [
            "income": income,
            "expense": expense,
            "currency": currencyCode,
            "month": MonthFormatting.longMonthYear(now),
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }

        guard let suite = UserDefaults(suiteName: AppConstants.appGroupIdentifier) else { return }
        suite.set(data, forKey: key)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
