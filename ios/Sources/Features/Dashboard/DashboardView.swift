//
//  DashboardView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @State private var viewModel: DashboardViewModel?
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
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.large)
            .onAppear {
                if viewModel == nil {
                    viewModel = DashboardViewModel(modelContext: modelContext)
                }
                reload()
            }
            .alert("Could not load data", isPresented: $loadError.alertPresented) {
                Button("OK") { loadError = nil }
            } message: {
                Text(loadError ?? "")
            }
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private func content(_ vm: DashboardViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.md) {

                MonthNavigationBar(monthTitle: vm.monthTitle) {
                    vm.shiftMonth(by: -1); reload()
                } onNext: {
                    vm.shiftMonth(by: 1); reload()
                }

                spendingRingCard(vm)

                deltaCard(vm)

                recentActivitySection(vm)
            }
            .padding(.horizontal, ESTTheme.Spacing.md)
            .padding(.vertical, ESTTheme.Spacing.sm)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Spending ring + summary card

    @ViewBuilder
    private func spendingRingCard(_ vm: DashboardViewModel) -> some View {
        ESTCard {
            HStack(spacing: ESTTheme.Spacing.lg) {
                SpendingRingView(income: vm.monthIncome, expense: vm.monthExpense)

                VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
                    metricRow(
                        icon: "arrow.down.circle.fill",
                        label: "Income",
                        value: MoneyFormatting.string(amount: vm.monthIncome, currencyCode: currencyCode),
                        color: ESTTheme.income
                    )
                    Divider()
                    metricRow(
                        icon: "arrow.up.circle.fill",
                        label: "Expenses",
                        value: MoneyFormatting.string(amount: vm.monthExpense, currencyCode: currencyCode),
                        color: ESTTheme.expense
                    )
                    Divider()
                    metricRow(
                        icon: vm.savings >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                        label: "Saved",
                        value: MoneyFormatting.string(amount: vm.savings, currencyCode: currencyCode),
                        color: vm.savings >= 0 ? ESTTheme.savings : .red
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    private func metricRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(ESTTheme.caption2Font)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(ESTTheme.subheadlineFont.monospacedDigit())
                    .foregroundStyle(color)
            }
        }
    }

    // MARK: - vs Previous month delta card

    @ViewBuilder
    private func deltaCard(_ vm: DashboardViewModel) -> some View {
        ESTCard {
            VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
                Text("vs previous month")
                    .font(ESTTheme.headlineFont)

                HStack(spacing: 0) {
                    deltaColumn(
                        label: "Income",
                        current: vm.monthIncome,
                        prior: vm.priorMonthIncome,
                        higherIsBetter: true
                    )
                    Divider().frame(height: 44)
                    deltaColumn(
                        label: "Expenses",
                        current: vm.monthExpense,
                        prior: vm.priorMonthExpense,
                        higherIsBetter: false
                    )
                    Divider().frame(height: 44)
                    deltaColumn(
                        label: "Savings",
                        current: vm.savings,
                        prior: vm.priorMonthIncome - vm.priorMonthExpense,
                        higherIsBetter: true
                    )
                }
            }
        }
    }

    private func deltaColumn(label: String, current: Double, prior: Double, higherIsBetter: Bool) -> some View {
        let delta = current - prior
        let pct: Double? = prior != 0 ? (delta / abs(prior)) * 100 : nil
        let color = ESTTheme.deltaColor(delta: delta, higherIsBetter: higherIsBetter)

        return VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(ESTTheme.caption2Font)
                .foregroundStyle(.secondary)
            HStack(spacing: 2) {
                Image(systemName: delta > 0 ? "arrow.up.right" : delta < 0 ? "arrow.down.right" : "minus")
                    .font(.caption2.weight(.bold))
                if let pct {
                    Text(String(format: "%+.1f%%", pct))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                } else {
                    Text("—")
                        .font(ESTTheme.captionFont)
                }
            }
            .foregroundStyle(color)
            Text(MoneyFormatting.string(amount: abs(delta), currencyCode: currencyCode))
                .font(ESTTheme.caption2Font)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recent activity

    @ViewBuilder
    private func recentActivitySection(_ vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: ESTTheme.Spacing.sm) {
            HStack {
                Text("Recent activity")
                    .font(ESTTheme.headlineFont)
                Spacer()
                if !vm.recentTransactions.isEmpty {
                    ESTPill(label: "\(vm.recentTransactions.count) shown", color: .secondary)
                }
            }
            .padding(.horizontal, 2)

            if vm.recentTransactions.isEmpty {
                EmptyStateView(
                    systemImage: "tray",
                    title: "No transactions yet",
                    message: "Add a salary or expense from the Add Entry tab, or load sample data in Settings."
                )
            } else {
                VStack(spacing: ESTTheme.Spacing.xs) {
                    ForEach(vm.recentTransactions, id: \.id) { entry in
                        TransactionRowView(entry: entry, currencyCode: currencyCode)
                    }
                }
            }
        }
        .padding(.top, ESTTheme.Spacing.xs)
    }

    // MARK: - Helpers

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

// MARK: - Spending ring

private struct SpendingRingView: View {
    let income: Double
    let expense: Double

    private var ratio: Double {
        guard income > 0 else { return expense > 0 ? 1 : 0 }
        return min(expense / income, 1.0)
    }

    private var ringColor: Color {
        ESTTheme.ringColor(ratio: ratio)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 14)

            Circle()
                .trim(from: 0, to: ratio)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.7, bounce: 0.15), value: ratio)

            VStack(spacing: 1) {
                Text("\(Int(ratio * 100))%")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(ringColor)
                    .contentTransition(.numericText())
                Text("spent")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 96, height: 96)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: TransactionEntry.self, inMemory: true)
        .environment(\.currencyCode, "USD")
}
