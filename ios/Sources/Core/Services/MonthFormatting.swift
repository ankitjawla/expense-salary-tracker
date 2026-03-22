//
//  MonthFormatting.swift
//  Expense & Salary Tracker
//

import Foundation

/// Locale-aware month strings shared by view models (avoids ad hoc `DateFormatter` churn).
enum MonthFormatting {
    static func longMonthYear(_ date: Date, locale: Locale = .current) -> String {
        date.formatted(.dateTime.locale(locale).month(.wide).year())
    }

    static func shortMonth(_ date: Date, locale: Locale = .current) -> String {
        date.formatted(.dateTime.locale(locale).month(.abbreviated))
    }
}
