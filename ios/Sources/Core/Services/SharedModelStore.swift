//
//  SharedModelStore.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

/// Single SwiftData container (App Group) shared by the app, App Intents, and background hooks.
enum SharedModelStore {
    static let shared: ModelContainer = {
        let schema = Schema([
            TransactionEntry.self,
            ExpenseBudget.self,
            RecurringReminder.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(AppConstants.appGroupIdentifier)
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }()
}
