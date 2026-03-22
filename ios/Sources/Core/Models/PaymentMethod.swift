//
//  PaymentMethod.swift
//  Expense & Salary Tracker
//

import Foundation

enum PaymentMethod: String, Codable, CaseIterable, Identifiable, Sendable {
    case unspecified
    case cash
    case debitCard
    case creditCard
    case bankTransfer
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unspecified: return "Not set"
        case .cash: return "Cash"
        case .debitCard: return "Debit card"
        case .creditCard: return "Credit card"
        case .bankTransfer: return "Bank transfer"
        case .other: return "Other"
        }
    }
}
