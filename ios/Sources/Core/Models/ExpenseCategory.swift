//
//  ExpenseCategory.swift
//  Expense & Salary Tracker
//

import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case food
    case transport
    case housing
    case utilities
    case entertainment
    case health
    case shopping
    case education
    case subscriptions
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food: return "Food & Dining"
        case .transport: return "Transport"
        case .housing: return "Housing"
        case .utilities: return "Utilities"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .shopping: return "Shopping"
        case .education: return "Education"
        case .subscriptions: return "Subscriptions"
        case .other: return "Other"
        }
    }

    var systemImageName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .housing: return "house"
        case .utilities: return "bolt"
        case .entertainment: return "theatermasks"
        case .health: return "cross.case"
        case .shopping: return "bag"
        case .education: return "book"
        case .subscriptions: return "repeat"
        case .other: return "ellipsis.circle"
        }
    }
}
