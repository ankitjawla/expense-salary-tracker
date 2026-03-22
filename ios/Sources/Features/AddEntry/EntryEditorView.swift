//
//  EntryEditorView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct EntryEditorView: View {
    let entry: TransactionEntry
    var onDone: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currencyCode) private var currencyCode

    @State private var form: TransactionFormViewModel
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var confirmDelete = false

    init(entry: TransactionEntry, onDone: @escaping () -> Void) {
        self.entry = entry
        self.onDone = onDone
        _form = State(initialValue: TransactionFormViewModel(entry: entry))
    }

    var body: some View {
        TransactionFormView(viewModel: form)
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onDone()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!form.isValid)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .alert("Something went wrong", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(errorMessage ?? "")
            })
            .confirmationDialog("Delete this entry?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteEntry()
                }
                Button("Cancel", role: .cancel) {}
            }
    }

    private func save() {
        do {
            let updated = try form.save(using: modelContext)
            TransactionSaveSideEffects.run(modelContext: modelContext, currencyCode: currencyCode, touchedEntry: updated)
            Haptics.success()
            dismiss()
            onDone()
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func deleteEntry() {
        let removedId = entry.id
        modelContext.delete(entry)
        do {
            try modelContext.save()
            TransactionSaveSideEffects.afterDelete(modelContext: modelContext, currencyCode: currencyCode, removedId: removedId)
            Haptics.lightTap()
            dismiss()
            onDone()
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}
