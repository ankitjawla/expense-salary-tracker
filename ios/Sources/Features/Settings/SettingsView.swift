//
//  SettingsView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode = "USD"
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = SettingsViewModel()

    @State private var sampleError: String?
    @State private var showSampleError = false
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var showExportError = false

    private var appearanceMode: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Color scheme", selection: appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                }

                Section("Security") {
                    Toggle("App lock (Face ID / Touch ID)", isOn: $appLockEnabled)
                    Text("When enabled, biometrics are required after leaving the app. Data never leaves your device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Currency") {
                    Picker("Currency", selection: $selectedCurrencyCode) {
                        ForEach(CurrencyOption.allCases) { option in
                            Text(option.title).tag(option.code)
                        }
                    }
                    Text("Amounts are stored as entered. The currency setting controls how numbers are formatted across the app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Privacy & data (on-device)") {
                    NavigationLink {
                        BudgetsManageView()
                    } label: {
                        Label("Expense budgets", systemImage: "chart.bar.doc.horizontal")
                    }
                    NavigationLink {
                        RecurringRemindersManageView()
                    } label: {
                        Label("Recurring reminders", systemImage: "bell.badge")
                    }
                    Button("Export transactions (CSV)") {
                        prepareExport()
                    }
                    if let exportURL {
                        ShareLink(item: exportURL, message: Text("Expense & Salary Tracker export")) {
                            Label("Share exported file", systemImage: "square.and.arrow.up")
                        }
                    }
                    Button("Rebuild Spotlight index") {
                        TransactionSaveSideEffects.fullReindex(modelContext: modelContext, currencyCode: selectedCurrencyCode)
                        Haptics.success()
                    }
                    Text("Spotlight search, Siri Shortcuts, budgets, and widgets use only local storage. No account is required.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Sample data") {
                    Button("Load sample transactions") {
                        loadSample()
                    }
                }

                Section("About") {
                    LabeledContent("App") {
                        Text("Expense & Salary Tracker")
                    }
                    LabeledContent("Storage") {
                        Text("On-device (SwiftData)")
                    }
                }

                Section("Help") {
                    Button("Show welcome screens again") {
                        hasCompletedOnboarding = false
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Could not add sample data", isPresented: $showSampleError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(sampleError ?? "")
            })
            .alert("Export failed", isPresented: $showExportError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(exportError ?? "")
            })
        }
    }

    private func prepareExport() {
        exportURL = nil
        do {
            let csv = try CSVExportService.buildCSV(modelContext: modelContext, currencyCode: selectedCurrencyCode)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("ExpenseTracker-export.csv")
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
        } catch {
            exportError = error.localizedDescription
            showExportError = true
        }
    }

    private func loadSample() {
        do {
            try viewModel.insertSampleTransactions(using: modelContext)
            TransactionSaveSideEffects.fullReindex(modelContext: modelContext, currencyCode: selectedCurrencyCode)
            Haptics.success()
        } catch {
            sampleError = error.localizedDescription
            showSampleError = true
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [TransactionEntry.self, ExpenseBudget.self, RecurringReminder.self], inMemory: true)
        .environment(\.currencyCode, "USD")
}
