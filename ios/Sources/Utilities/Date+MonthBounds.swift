//
//  Date+MonthBounds.swift
//  Expense & Salary Tracker
//

import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }

    func endOfMonth(for date: Date) -> Date {
        let start = startOfMonth(for: date)
        guard let next = self.date(byAdding: .month, value: 1, to: start) else { return date }
        return self.date(byAdding: .second, value: -1, to: next) ?? date
    }

    func isDate(_ date: Date, inSameMonthAs other: Date) -> Bool {
        isDate(date, equalTo: other, toGranularity: .month)
    }
}

extension Date {
    func startOfMonth(calendar: Calendar = .current) -> Date {
        calendar.startOfMonth(for: self)
    }

    func endOfMonth(calendar: Calendar = .current) -> Date {
        calendar.endOfMonth(for: self)
    }
}
