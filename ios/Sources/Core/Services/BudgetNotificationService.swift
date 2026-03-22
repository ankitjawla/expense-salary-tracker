//
//  BudgetNotificationService.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData
import UserNotifications

enum BudgetNotificationService {
    private static let calendar = Calendar.current

    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    /// Call after transactions change; schedules at most one notification per budget category when threshold crossed.
    static func evaluateBudgets(modelContext: ModelContext, currencyCode: String) throws {
        let budgets = try modelContext.fetch(FetchDescriptor<ExpenseBudget>())
        let entries = try modelContext.fetch(FetchDescriptor<TransactionEntry>())
        let now = Date()
        let start = calendar.startOfMonth(for: now)
        let end = calendar.endOfMonth(for: now)

        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)

        for budget in budgets where budget.isEnabled && budget.notifyAtPercent > 0 {
            let spent = entries
                .filter { $0.kind == .expense && $0.date >= start && $0.date <= end }
                .filter { $0.expenseCategory == budget.expenseCategory }
                .reduce(0) { $0 + $1.amount }

            let limit = budget.monthlyLimit
            guard limit > 0 else { continue }
            let ratio = spent / limit
            let threshold = budget.notifyAtPercent / 100
            guard ratio >= threshold else { continue }

            let dedupeKey = "budget_alert_\(budget.id.uuidString)_\(year)_\(month)"
            if UserDefaults.standard.bool(forKey: dedupeKey) { continue }
            UserDefaults.standard.set(true, forKey: dedupeKey)

            let id = "budget-\(budget.id.uuidString)-\(month)-\(year)"
            let content = UNMutableNotificationContent()
            content.title = "Budget alert"
            let pct = Int(min(999, ratio * 100))
            content.body = "\(budget.expenseCategory.title): spent \(pct)% of your monthly limit (\(MoneyFormatting.string(amount: spent, currencyCode: currencyCode)) of \(MoneyFormatting.string(amount: limit, currencyCode: currencyCode)))."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
