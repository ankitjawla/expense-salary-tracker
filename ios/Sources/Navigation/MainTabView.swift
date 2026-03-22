//
//  MainTabView.swift
//  Expense & Salary Tracker
//

import SwiftData
import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(AppTab.dashboard.title, systemImage: selectedTab == .dashboard
                          ? AppTab.dashboard.selectedImage
                          : AppTab.dashboard.systemImage)
                }
                .tag(AppTab.dashboard)

            TransactionsView()
                .tabItem {
                    Label(AppTab.transactions.title, systemImage: selectedTab == .transactions
                          ? AppTab.transactions.selectedImage
                          : AppTab.transactions.systemImage)
                }
                .tag(AppTab.transactions)

            AddEntryView(onSaved: { selectedTab = .transactions })
                .tabItem {
                    Label(AppTab.addEntry.title, systemImage: AppTab.addEntry.systemImage)
                }
                .tag(AppTab.addEntry)

            AnalyticsView()
                .tabItem {
                    Label(AppTab.analytics.title, systemImage: selectedTab == .analytics
                          ? AppTab.analytics.selectedImage
                          : AppTab.analytics.systemImage)
                }
                .tag(AppTab.analytics)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: selectedTab == .settings
                          ? AppTab.settings.selectedImage
                          : AppTab.settings.systemImage)
                }
                .tag(AppTab.settings)
        }
        .tint(ESTTheme.accent)
        .onAppear {
            styleTabBar()
            try? RecurringReminderScheduler.rescheduleAll(modelContext: modelContext)
        }
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: TransactionEntry.self, inMemory: true)
        .environment(\.currencyCode, "USD")
}
