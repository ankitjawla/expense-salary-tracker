//
//  AppTab.swift
//  Expense & Salary Tracker
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case dashboard
    case transactions
    case addEntry
    case analytics
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard:    return "Dashboard"
        case .transactions: return "Transactions"
        case .addEntry:     return "Add Entry"
        case .analytics:    return "Analytics"
        case .settings:     return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:    return "chart.pie"
        case .transactions: return "list.bullet"
        case .addEntry:     return "plus.circle.fill"
        case .analytics:    return "chart.xyaxis.line"
        case .settings:     return "gearshape"
        }
    }

    var selectedImage: String {
        switch self {
        case .dashboard:    return "chart.pie.fill"
        case .transactions: return "list.bullet.rectangle.fill"
        case .addEntry:     return "plus.circle.fill"
        case .analytics:    return "chart.xyaxis.line"
        case .settings:     return "gearshape.fill"
        }
    }
}
