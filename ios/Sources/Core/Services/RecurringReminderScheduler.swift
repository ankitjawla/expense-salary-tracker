//
//  RecurringReminderScheduler.swift
//  Expense & Salary Tracker
//

import Foundation
import SwiftData
import UserNotifications

enum RecurringReminderScheduler {
    static func rescheduleAll(modelContext: ModelContext) throws {
        let items = try modelContext.fetch(FetchDescriptor<RecurringReminder>())
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for item in items where item.isEnabled {
            schedule(item)
        }
    }

    static func schedule(_ item: RecurringReminder) {
        var components = DateComponents()
        components.day = item.dayOfMonth
        components.hour = 9
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Recurring: \(item.title)"
        content.body = "Suggested amount \(item.amountHint). Add it in Expense & Salary Tracker."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: item.notificationRequestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(_ item: RecurringReminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.notificationRequestIdentifier])
    }
}
