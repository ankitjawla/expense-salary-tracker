//
//  AddEntryView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct AddEntryView: View {
    var onSaved: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @State private var form = TransactionFormViewModel()
    @State private var quickAddText = ""
    @State private var parsePreview: String? = nil
    @State private var errorMessage: String?
    @State private var showValidationAlert = false
    @FocusState private var quickAddFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                quickAddSection
                TransactionFormFields(viewModel: form)
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        form.resetForNewEntry()
                        quickAddText = ""
                    }
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .buttonStyle(.borderless)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!form.isValid)
                        .buttonStyle(.borderless)
                }
            }
            .alert("Check your entry", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please enter a title and a valid amount.")
            }
        }
        .onAppear {
            BudgetNotificationService.requestAuthorizationIfNeeded()
        }
    }

    // MARK: - Quick-add section

    private var quickAddSection: some View {
        Section {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ESTTheme.accent)
                    .frame(width: 20)

                TextField("e.g. Coffee 4.50 or +500 salary", text: $quickAddText)
                    .textInputAutocapitalization(.never)
                    .focused($quickAddFocused)
                    .onChange(of: quickAddText) { _, newValue in
                        updateParsePreview(newValue)
                    }
                    .submitLabel(.done)
                    .onSubmit { applyQuickAdd() }

                if !quickAddText.isEmpty {
                    Button {
                        applyQuickAdd()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .foregroundStyle(parsePreview != nil ? ESTTheme.accent : Color.secondary)
                    }
                    .disabled(parsePreview == nil)
                    .buttonStyle(.borderless)
                    .animation(.easeInOut(duration: 0.2), value: parsePreview != nil)
                }
            }

            if let preview = parsePreview {
                Label(preview, systemImage: "checkmark.circle.fill")
                    .font(ESTTheme.captionFont)
                    .foregroundStyle(ESTTheme.income)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        } header: {
            Text("Quick add")
        } footer: {
            Text("Type an amount to auto-fill the form. Start with + or 'income' for income; add 'yesterday' to shift the date.")
                .font(ESTTheme.captionFont)
        }
    }

    // MARK: - Actions

    private func updateParsePreview(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let result = QuickTransactionParser.parse(trimmed) else {
            withAnimation { parsePreview = nil }
            return
        }
        let kindLabel = result.kind == .income ? "Income" : "Expense"
        let amtLabel = MoneyFormatting.string(amount: result.amount, currencyCode: currencyCode)
        withAnimation(.easeInOut(duration: 0.2)) {
            parsePreview = "\(kindLabel) · \(result.title) · \(amtLabel)"
        }
    }

    private func applyQuickAdd() {
        let trimmed = quickAddText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let result = QuickTransactionParser.parse(trimmed) else {
            errorMessage = "Could not parse. Include an amount (e.g. 12.99)."
            showValidationAlert = true
            return
        }
        form.applyQuickParseResult(result)
        quickAddText = ""
        parsePreview = nil
        quickAddFocused = false
        Haptics.lightTap()
    }

    private func save() {
        guard form.isValid else {
            errorMessage = "Enter a title and an amount greater than zero."
            showValidationAlert = true
            return
        }
        do {
            let entry = try form.save(using: modelContext)
            TransactionSaveSideEffects.run(modelContext: modelContext, currencyCode: currencyCode, touchedEntry: entry)
            Haptics.success()
            form.resetForNewEntry()
            quickAddText = ""
            parsePreview = nil
            onSaved()
        } catch {
            errorMessage = error.localizedDescription
            showValidationAlert = true
        }
    }
}

#Preview {
    AddEntryView(onSaved: {})
        .modelContainer(for: TransactionEntry.self, inMemory: true)
        .environment(\.currencyCode, "USD")
}
