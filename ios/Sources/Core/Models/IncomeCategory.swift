//
//  IncomeCategory.swift
//  Expense & Salary Tracker
//

import Foundation

enum IncomeCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case salary
    case freelance
    case investment
    case gift
    case bonus
    case refund
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .salary: return "Salary"
        case .freelance: return "Freelance"
        case .investment: return "Investment"
        case .gift: return "Gift"
        case .bonus: return "Bonus"
        case .refund: return "Refund"
        case .other: return "Other"
        }
    }

    var systemImageName: String {
        switch self {
        case .salary: return "banknote"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .gift: return "gift"
        case .bonus: return "star"
        case .refund: return "arrow.uturn.backward.circle"
        case .other: return "ellipsis.circle"
        }
    }
}
