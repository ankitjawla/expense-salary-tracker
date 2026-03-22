# Expense & Salary Tracker

Native **iPhone** app for tracking **income** and **expenses** with a clear dashboard, analytics, and local-only storage. Built with **Swift**, **SwiftUI**, **MVVM**, **SwiftData**, and **Charts** (iOS 17+).

**Repository:** [github.com/ankitjawla/expense-salary-tracker](https://github.com/ankitjawla/expense-salary-tracker)

## Requirements

- **Xcode** 15+ (CI uses the default `Xcode.app` on `macos-latest`)
- **iOS 17.0+** deployment target
- **iPhone** (portrait-oriented UI)

## Open and run

```bash
cd ios
open ExpenseSalaryTracker.xcodeproj
```

1. Select the **ExpenseSalaryTracker** scheme.
2. Choose a simulator or a connected device.
3. **Run** (⌘R).

### Command-line build

```bash
cd ios
xcodebuild -project ExpenseSalaryTracker.xcodeproj \
  -scheme ExpenseSalaryTracker \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Project layout

```
ios/
├── ExpenseSalaryTracker.xcodeproj/     # App + embedded widget extension
├── ExpenseSalaryTracker.entitlements   # App Groups (SwiftData + widget)
├── ExpenseSalaryTrackerWidgetExtension.entitlements
├── ExpenseSalaryTrackerWidget/         # WidgetKit extension (month summary)
├── Package.swift                       # Reference (app does not rely on SPM for the main target)
└── Sources/
    ├── App/                            # @main, app lock, SwiftData container
    ├── Core/                           # SwiftData models, services (export, Spotlight, notifications)
    ├── Features/                       # Dashboard, Transactions, Add/Edit, Analytics, Budgets, Recurring, Settings, Onboarding
    ├── Navigation/                     # Tab bar
    ├── Intents/                        # App Intents (log income / expense)
    ├── UI/                             # Theme (ESTTheme), reusable components
    ├── Utilities/                    # Haptics, appearance, bindings, dates
    ├── Assets.xcassets/
    └── Info.plist
```

## Features

| Area | What it does |
|------|----------------|
| **Dashboard** | Month navigation, income / expenses / savings, spending ring vs income, comparison vs previous month, recent activity |
| **Transactions** | Search, kind and category filters, “this month” toggle, swipe to delete, tap to edit |
| **Add entry** | Quick-add parser, income/expense, categories, payment method, optional receipt photo, notes |
| **Analytics** | YTD totals, 6-month cashflow bars, donut by expense category |
| **Budgets** | Per–expense-category monthly limits, progress vs current month spend, local notifications at a threshold |
| **Recurring** | Monthly reminders (notification) with title, amount hint, and category |
| **Settings** | Currency, light / dark / system, **App Lock** (Face ID / Touch ID / device passcode), CSV export, Spotlight reindex, sample data, replay onboarding |
| **Widget** | Home Screen “This month” snapshot (income / expense via App Group) |
| **Shortcuts** | App Intents to log income or expense (configure phrases in the Shortcuts app) |

Data stays **on device** via SwiftData, with an **App Group** container so the widget and intents can share the same store.

## Configuration before release

1. **Bundle identifier** — Replace `com.example.expensesalarytracker` (and `com.example.expensesalarytracker.widget`) in Xcode **Signing & Capabilities** with your own IDs.
2. **App Group** — Replace `group.com.example.expensesalarytracker` in:
   - Both entitlements files
   - `AppConstants.appGroupIdentifier` in code  
   Create the same group in the Apple Developer portal for your team.
3. **Development Team** — Set your team in the app and widget targets for device builds and App Store upload.

## App Lock and Simulator

Biometrics are often **unavailable in the Simulator**. If App Lock is enabled and you cannot authenticate, use **Turn off App Lock…** on the lock screen (or disable App Lock on a physical device). Prefer testing lock behavior on real hardware.

## CI

[GitHub Actions](.github/workflows/ci.yml) builds the **ExpenseSalaryTracker** scheme on `push` and `pull_request` to `main` (iOS Simulator, generic destination).

## License

[MIT License](LICENSE) — Copyright (c) 2026 Ankit Jawla.
