//
//  MonthNavigationBar.swift
//  Expense & Salary Tracker
//

import SwiftUI

/// Shared previous / next month control used on Dashboard and Analytics.
struct MonthNavigationBar: View {
    let monthTitle: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 44, height: 38)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Previous month")

            Text(monthTitle)
                .font(ESTTheme.headlineFont)
                .multilineTextAlignment(.center)
                .frame(minWidth: 160)
                .accessibilityAddTraits(.isHeader)

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 44, height: 38)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Next month")
        }
        .foregroundStyle(.primary)
        .buttonStyle(.borderless)
        .background(.fill.tertiary, in: Capsule(style: .continuous))
        .frame(maxWidth: .infinity)
    }
}
