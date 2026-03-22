//
//  ESTTheme.swift
//  Expense & Salary Tracker
//

import SwiftUI

enum ESTTheme {
    // MARK: - Semantic colors
    static let accent   = Color("AccentColor")
    static let income   = Color.green
    static let expense  = Color.orange
    static let savings  = Color.blue

    // MARK: - Tinted category-light colors (for backgrounds / icons)
    static let incomeLight  = Color.green.opacity(0.12)
    static let expenseLight = Color.orange.opacity(0.12)
    static let savingsLight = Color.blue.opacity(0.12)

    // MARK: - Layout
    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let rowPadding: CGFloat = 14

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Typography
    static let titleFont       = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headlineFont    = Font.system(.headline, design: .rounded)
    static let subheadlineFont = Font.system(.subheadline, design: .rounded)
    static let bodyFont        = Font.system(.body, design: .default)
    static let captionFont     = Font.system(.caption, design: .rounded)
    static let caption2Font    = Font.system(.caption2, design: .rounded)
    static let monoAmountFont  = Font.system(.body, design: .rounded).weight(.semibold).monospacedDigit()
    static let largeAmountFont = Font.system(.title, design: .rounded).weight(.bold).monospacedDigit()

    // MARK: - Progress ring color
    static func ringColor(ratio: Double) -> Color {
        ratio > 0.9 ? .red : ratio > 0.7 ? .orange : income
    }

    // MARK: - Delta color (income: up = good; expense: up = bad)
    static func deltaColor(delta: Double, higherIsBetter: Bool) -> Color {
        guard delta != 0 else { return .secondary }
        return (delta > 0) == higherIsBetter ? income : expense
    }
}

// MARK: - Card with material background + hairline border

struct ESTCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(ESTTheme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay {
                RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 0.5)
            }
    }
}

// MARK: - Card with colored left accent bar

struct ESTAccentCard<Content: View>: View {
    let tint: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            tint
                .frame(width: 4)
            content()
                .padding(ESTTheme.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(tint.opacity(0.18), lineWidth: 0.5)
        }
    }
}

// MARK: - Metric pill badge

struct ESTPill: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(ESTTheme.caption2Font.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: Capsule(style: .continuous))
    }
}
