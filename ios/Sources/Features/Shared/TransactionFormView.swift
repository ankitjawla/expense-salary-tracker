//
//  TransactionFormView.swift
//  Expense & Salary Tracker
//

import PhotosUI
import SwiftUI

struct TransactionFormFields: View {
    @Bindable var viewModel: TransactionFormViewModel
    @FocusState private var focusedField: Field?

    @State private var photoPickerItem: PhotosPickerItem?

    private enum Field: Hashable {
        case title
        case amount
        case notes
    }

    var body: some View {
        Group {
            Section {
                Picker("Type", selection: $viewModel.kind) {
                    ForEach(TransactionKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            }

            Section("Details") {
                TextField("Title", text: $viewModel.title)
                    .focused($focusedField, equals: .title)
                    .textInputAutocapitalization(.sentences)

                TextField("Amount", text: $viewModel.amountText)
                    .focused($focusedField, equals: .amount)
                    .keyboardType(.decimalPad)
                    .monospacedDigit()

                Button {
                    viewModel.applySmartCategoryFromTitle()
                    Haptics.lightTap()
                } label: {
                    Label("Suggest category from title", systemImage: "wand.and.stars")
                }

                if viewModel.kind == .income {
                    Picker("Category", selection: $viewModel.incomeCategory) {
                        ForEach(IncomeCategory.allCases) { category in
                            Label(category.title, systemImage: category.systemImageName).tag(category)
                        }
                    }
                } else {
                    Picker("Category", selection: $viewModel.expenseCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.title, systemImage: category.systemImageName).tag(category)
                        }
                    }
                }

                Picker("Payment method", selection: $viewModel.paymentMethod) {
                    ForEach(PaymentMethod.allCases) { method in
                        Text(method.title).tag(method)
                    }
                }

                TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                    .focused($focusedField, equals: .notes)
                    .lineLimit(3, reservesSpace: true)
            }

            Section("Receipt (optional)") {
                let hasReceipt = viewModel.receiptImageData != nil
                PhotosPicker(selection: $photoPickerItem, matching: .images, photoLibrary: .shared()) {
                    Label(
                        hasReceipt ? "Change receipt photo" : "Add receipt photo",
                        systemImage: "doc.viewfinder"
                    )
                }
                .onChange(of: photoPickerItem) { _, newItem in
                    guard let newItem else { return }
                    Task { @MainActor in
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            viewModel.receiptImageData = data
                        }
                    }
                }
                if hasReceipt {
                    Button("Remove receipt", role: .destructive) {
                        viewModel.receiptImageData = nil
                        photoPickerItem = nil
                    }
                }
            }
        }
    }
}

struct TransactionFormView: View {
    @Bindable var viewModel: TransactionFormViewModel

    var body: some View {
        Form {
            TransactionFormFields(viewModel: viewModel)
        }
    }
}
