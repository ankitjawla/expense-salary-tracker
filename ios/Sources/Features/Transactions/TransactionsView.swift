//
//  TransactionsView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @State private var viewModel: TransactionsViewModel?
    @State private var editingPresentation: EditingTransaction?
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    listContent(viewModel)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Transactions")
            .toolbarTitleDisplayMode(.large)
            .searchable(text: bindingSearchText, prompt: "Search title or notes")
            .onAppear {
                if viewModel == nil {
                    viewModel = TransactionsViewModel(modelContext: modelContext)
                }
                reload()
            }
            .sheet(item: $editingPresentation) { wrap in
                NavigationStack {
                    EntryEditorView(entry: wrap.entry) {
                        editingPresentation = nil
                        reload()
                    }
                }
            }
            .alert("Could not update data", isPresented: $loadError.alertPresented) {
                Button("OK") { loadError = nil }
            } message: {
                Text(loadError ?? "")
            }
        }
    }

    private var bindingSearchText: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }

    @ViewBuilder
    private func listContent(_ vm: TransactionsViewModel) -> some View {
        List {
            Section {
                Picker("Type", selection: Binding(
                    get: { vm.kindFilter },
                    set: { vm.kindFilter = $0 }
                )) {
                    ForEach(TransactionsKindFilter.allCases) { f in
                        Text(f.title).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                Toggle("This month only", isOn: Binding(
                    get: { vm.restrictToCurrentMonth },
                    set: { vm.restrictToCurrentMonth = $0 }
                ))

                categoryFilters(vm)
            }

            if vm.filteredEntries.isEmpty {
                Section {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "No matches",
                        message: "Try adjusting filters or search, or add a new entry."
                    )
                    .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(vm.filteredEntries, id: \.id) { entry in
                        Button {
                            editingPresentation = EditingTransaction(entry)
                        } label: {
                            TransactionRowView(entry: entry, currencyCode: currencyCode)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(entry, vm: vm)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func categoryFilters(_ vm: TransactionsViewModel) -> some View {
        switch vm.kindFilter {
        case .all:
            IncomeCategoryFilterPicker(selection: Binding(
                get: { vm.selectedIncomeCategory },
                set: { vm.selectedIncomeCategory = $0 }
            ))
            ExpenseCategoryFilterPicker(selection: Binding(
                get: { vm.selectedExpenseCategory },
                set: { vm.selectedExpenseCategory = $0 }
            ))
        case .income:
            IncomeCategoryFilterPicker(selection: Binding(
                get: { vm.selectedIncomeCategory },
                set: { vm.selectedIncomeCategory = $0 }
            ))
        case .expense:
            ExpenseCategoryFilterPicker(selection: Binding(
                get: { vm.selectedExpenseCategory },
                set: { vm.selectedExpenseCategory = $0 }
            ))
        }
    }

    private func delete(_ entry: TransactionEntry, vm: TransactionsViewModel) {
        let removedId = entry.id
        do {
            try vm.delete(entry)
            TransactionSaveSideEffects.afterDelete(modelContext: modelContext, currencyCode: currencyCode, removedId: removedId)
        } catch {
            loadError = error.localizedDescription
        }
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

private struct IncomeCategoryFilterPicker: View {
    @Binding var selection: IncomeCategory?

    var body: some View {
        Picker("Income category", selection: $selection) {
            Text("Any income category").tag(Optional<IncomeCategory>.none)
            ForEach(IncomeCategory.allCases) { category in
                Text(category.title).tag(Optional(category))
            }
        }
    }
}

private struct ExpenseCategoryFilterPicker: View {
    @Binding var selection: ExpenseCategory?

    var body: some View {
        Picker("Expense category", selection: $selection) {
            Text("Any expense category").tag(Optional<ExpenseCategory>.none)
            ForEach(ExpenseCategory.allCases) { category in
                Text(category.title).tag(Optional(category))
            }
        }
    }
}

struct EditingTransaction: Identifiable {
    let id: UUID
    let entry: TransactionEntry

    init(_ entry: TransactionEntry) {
        self.entry = entry
        self.id = entry.id
    }
}

#Preview {
    TransactionsView()
        .modelContainer(for: TransactionEntry.self, inMemory: true)
        .environment(\.currencyCode, "USD")
}
