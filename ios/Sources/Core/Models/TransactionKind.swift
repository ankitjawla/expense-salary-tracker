//
//  TransactionKind.swift
//  Expense & Salary Tracker
//

import Foundation

enum TransactionKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case income
    case expense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        }
    }
}
