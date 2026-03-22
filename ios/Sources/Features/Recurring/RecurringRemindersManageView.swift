//
//  RecurringRemindersManageView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct RecurringRemindersManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @Query(sort: \RecurringReminder.title) private var reminders: [RecurringReminder]

    @State private var showAdd = false

    var body: some View {
        List {
            if reminders.isEmpty {
                ContentUnavailableView(
                    "No reminders",
                    systemImage: "bell.badge",
                    description: Text("Get a monthly local notification to add recurring bills or salary. Data stays on your iPhone.")
                )
            } else {
                ForEach(reminders) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text("\(item.kind.title) · day \(item.dayOfMonth) · ~\(MoneyFormatting.string(amount: item.amountHint, currencyCode: currencyCode))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(item.isEnabled ? "Scheduled" : "Paused")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            RecurringReminderScheduler.cancel(item)
                            modelContext.delete(item)
                            try? modelContext.save()
                            try? RecurringReminderScheduler.rescheduleAll(modelContext: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Recurring reminders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AddRecurringFormView {
                    showAdd = false
                    try? RecurringReminderScheduler.rescheduleAll(modelContext: modelContext)
                }
            }
        }
    }
}

private struct AddRecurringFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var amountText = ""
    @State private var kind: TransactionKind = .expense
    @State private var expenseCategory: ExpenseCategory = .housing
    @State private var incomeCategory: IncomeCategory = .salary
    @State private var dayOfMonth = 1

    var onDone: () -> Void

    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Suggested amount", text: $amountText)
                .keyboardType(.decimalPad)
            Picker("Type", selection: $kind) {
                ForEach(TransactionKind.allCases) { k in
                    Text(k.title).tag(k)
                }
            }
            .pickerStyle(.segmented)
            if kind == .expense {
                Picker("Category", selection: $expenseCategory) {
                    ForEach(ExpenseCategory.allCases) { c in
                        Text(c.title).tag(c)
                    }
                }
            } else {
                Picker("Category", selection: $incomeCategory) {
                    ForEach(IncomeCategory.allCases) { c in
                        Text(c.title).tag(c)
                    }
                }
            }
            Stepper("Day of month: \(dayOfMonth)", value: $dayOfMonth, in: 1...28)
        }
        .navigationTitle("New reminder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || MoneyFormatting.parseAmount(from: amountText) == nil)
            }
        }
    }

    private func save() {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amt = MoneyFormatting.parseAmount(from: amountText), amt > 0 else { return }
        let r = RecurringReminder(
            title: t,
            amountHint: amt,
            kind: kind,
            expenseCategory: kind == .expense ? expenseCategory : nil,
            incomeCategory: kind == .income ? incomeCategory : nil,
            dayOfMonth: dayOfMonth
        )
        modelContext.insert(r)
        try? modelContext.save()
        RecurringReminderScheduler.schedule(r)
        BudgetNotificationService.requestAuthorizationIfNeeded()
        dismiss()
        onDone()
    }
}
