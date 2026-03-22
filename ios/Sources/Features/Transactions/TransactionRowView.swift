//
//  TransactionRowView.swift
//  Expense & Salary Tracker
//

import SwiftUI

struct TransactionRowView: View {
    let entry: TransactionEntry
    let currencyCode: String

    var body: some View {
        HStack(spacing: 0) {
            // Left tinted accent bar
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(entry.kind == .income ? ESTTheme.income : ESTTheme.expense)
                .frame(width: 3)
                .padding(.vertical, 8)

            HStack(alignment: .center, spacing: 12) {
                // Category icon in tinted circle
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(entry.kind == .income ? ESTTheme.income : ESTTheme.expense)
                    .frame(width: 36, height: 36)
                    .background(
                        (entry.kind == .income ? ESTTheme.income : ESTTheme.expense).opacity(0.12),
                        in: Circle()
                    )

                // Title + subtitle
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.title)
                        .font(ESTTheme.headlineFont)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(categoryLabel)
                            .font(ESTTheme.captionFont)
                            .foregroundStyle(.secondary)
                        if let pay = paymentLabel {
                            Text("·")
                                .font(ESTTheme.captionFont)
                                .foregroundStyle(.tertiary)
                            Text(pay)
                                .font(ESTTheme.captionFont)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !entry.notes.isEmpty {
                        Text(entry.notes)
                            .font(ESTTheme.captionFont)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                // Right: amount + relative date + receipt badge
                VStack(alignment: .trailing, spacing: 3) {
                    Text(signedAmount)
                        .font(ESTTheme.monoAmountFont)
                        .foregroundStyle(entry.kind == .income ? ESTTheme.income : ESTTheme.expense)

                    Text(relativeDate)
                        .font(ESTTheme.caption2Font)
                        .foregroundStyle(.tertiary)

                    if entry.receiptImageData != nil {
                        Image(systemName: "paperclip")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, ESTTheme.rowPadding)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: ESTTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(
                    (entry.kind == .income ? ESTTheme.income : ESTTheme.expense).opacity(0.12),
                    lineWidth: 0.5
                )
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Computed helpers

    private var signedAmount: String {
        let formatted = MoneyFormatting.string(amount: entry.amount, currencyCode: currencyCode)
        return entry.kind == .income ? "+\(formatted)" : "-\(formatted)"
    }

    private var relativeDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(entry.date) { return "Today" }
        if calendar.isDateInYesterday(entry.date) { return "Yesterday" }
        let daysDiff = abs(calendar.dateComponents([.day], from: entry.date, to: .now).day ?? 8)
        if daysDiff < 7 {
            return entry.date.formatted(.dateTime.weekday(.wide))
        }
        return entry.date.formatted(date: .abbreviated, time: .omitted)
    }

    private var categoryLabel: String {
        switch entry.kind {
        case .income:  return entry.incomeCategory?.title  ?? "Income"
        case .expense: return entry.expenseCategory?.title ?? "Expense"
        }
    }

    private var paymentLabel: String? {
        entry.paymentMethod == .unspecified ? nil : entry.paymentMethod.title
    }

    private var iconName: String {
        switch entry.kind {
        case .income:  return entry.incomeCategory?.systemImageName  ?? "arrow.down.circle"
        case .expense: return entry.expenseCategory?.systemImageName ?? "arrow.up.circle"
        }
    }
}
