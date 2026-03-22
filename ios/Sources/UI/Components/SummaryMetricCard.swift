//
//  SummaryMetricCard.swift
//  Expense & Salary Tracker
//

import SwiftUI

struct SummaryMetricCard: View {
    let title: String
    let value: String
    let tint: Color
    var caption: String? = nil
    var systemImage: String? = nil
    var trendLabel: String? = nil
    var trendPositive: Bool? = nil

    var body: some View {
        ESTCard {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
                HStack(spacing: 6) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tint)
                            .frame(width: 26, height: 26)
                            .background(tint.opacity(0.12), in: Circle())
                    }
                    Text(title)
                        .font(ESTTheme.captionFont)
                        .foregroundStyle(.secondary)
                }

                Text(value)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())

                if let trendLabel, let positive = trendPositive {
                    HStack(spacing: 3) {
                        Image(systemName: positive ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2.weight(.bold))
                        Text(trendLabel)
                            .font(ESTTheme.caption2Font)
                    }
                    .foregroundStyle(positive ? ESTTheme.income : ESTTheme.expense)
                } else if let caption {
                    Text(caption)
                        .font(ESTTheme.captionFont)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
