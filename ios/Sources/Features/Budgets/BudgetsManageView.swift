//
//  BudgetsManageView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct BudgetsManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @Query(sort: \ExpenseBudget.expenseCategoryRaw) private var budgets: [ExpenseBudget]

    @State private var showAdd = false
    @State private var currentMonthSpends: [String: Double] = [:]

    var body: some View {
        List {
            if budgets.isEmpty {
                ContentUnavailableView(
                    "No budgets",
                    systemImage: "chart.bar.doc.horizontal",
                    description: Text("Add a monthly limit for an expense category. You get a local notification when spending crosses your alert threshold.")
                )
            } else {
                ForEach(budgets) { budget in
                    BudgetRowView(
                        budget: budget,
                        spent: currentMonthSpends[budget.expenseCategoryRaw, default: 0],
                        currencyCode: currencyCode
                    )
                    .swipeActions {
                        Button(role: .destructive) {
                            modelContext.delete(budget)
                            try? modelContext.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Budgets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AddBudgetFormView {
                    showAdd = false
                    try? BudgetNotificationService.evaluateBudgets(modelContext: modelContext, currencyCode: currencyCode)
                }
            }
        }
        .onAppear(perform: loadCurrentMonthSpends)
        .onChange(of: budgets.count) { _, _ in loadCurrentMonthSpends() }
    }

    private func loadCurrentMonthSpends() {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.startOfMonth(for: now)
        let end   = calendar.endOfMonth(for: now)
        let predicate = #Predicate<TransactionEntry> { e in
            e.date >= start && e.date <= end && e.kindRaw == "expense"
        }
        let desc = FetchDescriptor<TransactionEntry>(predicate: predicate)
        guard let entries = try? modelContext.fetch(desc) else { return }
        var result: [String: Double] = [:]
        for e in entries {
            if let cat = e.expenseCategoryRaw {
                result[cat, default: 0] += e.amount
            }
        }
        currentMonthSpends = result
    }
}

// MARK: - Budget row with progress bar

private struct BudgetRowView: View {
    let budget: ExpenseBudget
    let spent: Double
    let currencyCode: String

    private var ratio: Double {
        guard budget.monthlyLimit > 0 else { return 0 }
        return min(spent / budget.monthlyLimit, 1.0)
    }

    private var progressColor: Color {
        ratio > 0.9 ? .red : ratio > 0.7 ? .orange : .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: budget.expenseCategory.systemImageName)
                    .font(.subheadline)
                    .foregroundStyle(progressColor)
                    .frame(width: 22)

                Text(budget.expenseCategory.title)
                    .font(.headline)

                Spacer()

                Text(MoneyFormatting.string(amount: spent, currencyCode: currencyCode))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(progressColor)
                + Text(" / " + MoneyFormatting.string(amount: budget.monthlyLimit, currencyCode: currencyCode))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: ratio)
                .tint(progressColor)
                .animation(.spring(duration: 0.5), value: ratio)

            HStack {
                Text("\(Int(ratio * 100))% used")
                    .font(ESTTheme.caption2Font)
                    .foregroundStyle(progressColor)
                Spacer()
                if budget.notifyAtPercent > 0 {
                    ESTPill(label: "Alert at \(Int(budget.notifyAtPercent))%", color: .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add budget form

private struct AddBudgetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var category: ExpenseCategory = .food
    @State private var limitText = ""
    @State private var notifyPercent: Double = 80

    var onDone: () -> Void

    var body: some View {
        Form {
            Section("Category & limit") {
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases) { c in
                        Label(c.title, systemImage: c.systemImageName).tag(c)
                    }
                }
                HStack {
                    Text("Monthly limit")
                    Spacer()
                    TextField("0.00", text: $limitText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }
            }

            Section("Alerts") {
                Stepper(value: $notifyPercent, in: 0...100, step: 5) {
                    if notifyPercent == 0 {
                        Text("No alert")
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Text("Alert at")
                            Text("\(Int(notifyPercent))%")
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                            Text("of limit")
                        }
                    }
                }
            }
        }
        .navigationTitle("New budget")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .fontWeight(.semibold)
                    .disabled(MoneyFormatting.parseAmount(from: limitText) == nil)
            }
        }
    }

    private func save() {
        guard let lim = MoneyFormatting.parseAmount(from: limitText), lim > 0 else { return }
        let b = ExpenseBudget(category: category, monthlyLimit: lim, notifyAtPercent: notifyPercent)
        modelContext.insert(b)
        try? modelContext.save()
        BudgetNotificationService.requestAuthorizationIfNeeded()
        dismiss()
        onDone()
    }
}
