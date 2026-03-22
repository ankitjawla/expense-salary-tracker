//
//  AnalyticsView.swift
//  Expense & Salary Tracker
//

import Charts
import SwiftData
import SwiftUI

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @State private var viewModel: AnalyticsViewModel?
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Analytics")
            .toolbarTitleDisplayMode(.large)
            .onAppear {
                if viewModel == nil {
                    viewModel = AnalyticsViewModel(modelContext: modelContext)
                }
                reload()
            }
            .alert("Could not load analytics", isPresented: $loadError.alertPresented) {
                Button("OK") { loadError = nil }
            } message: {
                Text(loadError ?? "")
            }
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private func content(_ vm: AnalyticsViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.md) {

                MonthNavigationBar(monthTitle: vm.monthTitle) {
                    vm.shiftMonth(by: -1); reload()
                } onNext: {
                    vm.shiftMonth(by: 1); reload()
                }

                ytdCard(vm)
                cashflowCard(vm)
                categoryDonutCard(vm)
            }
            .padding(.horizontal, ESTTheme.Spacing.md)
            .padding(.vertical, ESTTheme.Spacing.sm)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - YTD card

    @ViewBuilder
    private func ytdCard(_ vm: AnalyticsViewModel) -> some View {
        ESTCard {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
                Text("Year \(vm.yearSummaryTitle)")
                    .font(ESTTheme.headlineFont)

                HStack(spacing: 0) {
                    ytdMetric(label: "Income YTD", value: vm.yearToDateIncome, color: ESTTheme.income)
                    Divider().frame(height: 44)
                    ytdMetric(label: "Expenses YTD", value: vm.yearToDateExpense, color: ESTTheme.expense)
                    Divider().frame(height: 44)
                    let netYTD = vm.yearToDateIncome - vm.yearToDateExpense
                    ytdMetric(
                        label: "Net YTD",
                        value: netYTD,
                        color: netYTD >= 0 ? ESTTheme.savings : .red
                    )
                }
            }
        }
    }

    private func ytdMetric(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(ESTTheme.caption2Font)
                .foregroundStyle(.secondary)
            Text(MoneyFormatting.string(amount: value, currencyCode: currencyCode))
                .font(.system(.callout, design: .rounded).weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Cashflow bar chart

    @ViewBuilder
    private func cashflowCard(_ vm: AnalyticsViewModel) -> some View {
        ESTCard {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cashflow")
                            .font(ESTTheme.headlineFont)
                        Text("Last 6 months")
                            .font(ESTTheme.captionFont)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: ESTTheme.Spacing.sm) {
                        legendDot(color: ESTTheme.income, label: "Income")
                        legendDot(color: ESTTheme.expense, label: "Expenses")
                    }
                }

                if vm.monthlyBars.allSatisfy({ $0.income == 0 && $0.expense == 0 }) {
                    emptyChartPlaceholder("No cashflow data yet.")
                } else {
                    Chart {
                        ForEach(vm.monthlyBars) { row in
                            BarMark(
                                x: .value("Month", row.label),
                                y: .value("Amount", row.income)
                            )
                            .foregroundStyle(ESTTheme.income.gradient)
                            .position(by: .value("Series", "Income"))
                            .cornerRadius(4)
                        }
                        ForEach(vm.monthlyBars) { row in
                            BarMark(
                                x: .value("Month", row.label),
                                y: .value("Amount", row.expense)
                            )
                            .foregroundStyle(ESTTheme.expense.gradient)
                            .position(by: .value("Series", "Expenses"))
                            .cornerRadius(4)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                            AxisValueLabel {
                                if let v = value.as(Double.self) {
                                    Text(abbreviatedAmount(v, currencyCode: currencyCode))
                                        .font(ESTTheme.caption2Font)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let label = value.as(String.self) {
                                    Text(label)
                                        .font(ESTTheme.caption2Font)
                                }
                            }
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(height: 220)
                    .padding(.top, ESTTheme.Spacing.sm)
                }
            }
        }
    }

    // MARK: - Category donut

    @ViewBuilder
    private func categoryDonutCard(_ vm: AnalyticsViewModel) -> some View {
        ESTCard {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Expenses by category")
                        .font(ESTTheme.headlineFont)
                    Text(vm.monthTitle)
                        .font(ESTTheme.captionFont)
                        .foregroundStyle(.secondary)
                }

                if vm.expenseSlices.isEmpty {
                    emptyChartPlaceholder("No expenses recorded for this month.")
                } else {
                    Chart(vm.expenseSlices) { slice in
                        SectorMark(
                            angle: .value("Amount", slice.amount),
                            innerRadius: .ratio(0.58),
                            angularInset: 1.5
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value("Category", slice.title))
                    }
                    .chartLegend(.hidden)
                    .frame(height: 220)
                    .padding(.top, ESTTheme.Spacing.xs)

                    // Manual legend with amounts
                    VStack(spacing: 6) {
                        ForEach(vm.expenseSlices.prefix(8)) { slice in
                            HStack(spacing: 8) {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundStyle(Color.accentColor)   // actual color managed by chart palette
                                Text(slice.title)
                                    .font(ESTTheme.captionFont)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(MoneyFormatting.string(amount: slice.amount, currencyCode: currencyCode))
                                    .font(ESTTheme.captionFont.monospacedDigit())
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .padding(.top, ESTTheme.Spacing.sm)
                }
            }
        }
    }

    // MARK: - Helpers

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(ESTTheme.caption2Font)
                .foregroundStyle(.secondary)
        }
    }

    private func emptyChartPlaceholder(_ message: String) -> some View {
        Text(message)
            .font(ESTTheme.captionFont)
            .foregroundStyle(.tertiary)
            .padding(.vertical, ESTTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private func abbreviatedAmount(_ value: Double, currencyCode: String) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        }
        return String(format: "%.0f", value)
    }

    private func reload() {
        guard let viewModel else { return }
        do {
            try viewModel.reload()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: TransactionEntry.self, inMemory: true)
}
