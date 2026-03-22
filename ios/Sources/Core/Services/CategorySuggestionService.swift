//
//  CategorySuggestionService.swift
//  Expense & Salary Tracker
//

import Foundation

/// On-device keyword + language heuristics for category hints (no network).
enum CategorySuggestionService {
    private static let expenseKeywords: [(ExpenseCategory, [String])] = [
        (.food, ["food", "grocery", "restaurant", "coffee", "lunch", "dinner", "uber eats", "doordash", "meal"]),
        (.transport, ["gas", "fuel", "uber", "lyft", "parking", "transit", "metro", "train", "flight", "taxi"]),
        (.housing, ["rent", "mortgage", "lease"]),
        (.utilities, ["electric", "water", "internet", "phone", "utility", "wifi"]),
        (.entertainment, ["movie", "concert", "game", "netflix", "spotify", "show"]),
        (.health, ["pharmacy", "doctor", "hospital", "dental", "gym", "fitness"]),
        (.shopping, ["amazon", "store", "clothes", "retail"]),
        (.education, ["tuition", "course", "book", "school"]),
        (.subscriptions, ["subscription", "icloud", "software", "saas"]),
    ]

    private static let incomeKeywords: [(IncomeCategory, [String])] = [
        (.salary, ["salary", "payroll", "paycheck", "wage"]),
        (.freelance, ["freelance", "invoice", "client", "contract"]),
        (.investment, ["dividend", "interest", "capital", "stock"]),
        (.gift, ["gift", "bonus", "present"]),
        (.refund, ["refund", "reimburse", "cashback"]),
    ]

    static func suggestExpenseCategory(for title: String) -> ExpenseCategory? {
        let lowered = title.lowercased()
        for (category, words) in expenseKeywords {
            if words.contains(where: { lowered.contains($0) }) {
                return category
            }
        }
        return nil
    }

    static func suggestIncomeCategory(for title: String) -> IncomeCategory? {
        let lowered = title.lowercased()
        for (category, words) in incomeKeywords {
            if words.contains(where: { lowered.contains($0) }) {
                return category
            }
        }
        return nil
    }
}
