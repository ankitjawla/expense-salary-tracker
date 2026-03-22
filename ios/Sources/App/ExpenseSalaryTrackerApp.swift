//
//  ExpenseSalaryTrackerApp.swift
//  Expense & Salary Tracker
//

import SwiftUI
import SwiftData

@main
struct ExpenseSalaryTrackerApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode = "USD"

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            AppLockGate {
                Group {
                    if hasCompletedOnboarding {
                        MainTabView()
                    } else {
                        OnboardingView()
                    }
                }
                .preferredColorScheme(appearanceMode.colorScheme)
                .environment(\.currencyCode, selectedCurrencyCode)
            }
            .modelContainer(SharedModelStore.shared)
        }
    }
}

private struct CurrencyCodeKey: EnvironmentKey {
    static let defaultValue: String = "USD"
}

extension EnvironmentValues {
    var currencyCode: String {
        get { self[CurrencyCodeKey.self] }
        set { self[CurrencyCodeKey.self] = newValue }
    }
}
