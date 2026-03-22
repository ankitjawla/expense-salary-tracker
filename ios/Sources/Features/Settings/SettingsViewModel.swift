//
//  SettingsViewModel.swift
//  Expense & Salary Tracker
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class SettingsViewModel {
    func insertSampleTransactions(using modelContext: ModelContext) throws {
        try SampleDataSeeder.insertSampleTransactions(into: modelContext)
    }
}
