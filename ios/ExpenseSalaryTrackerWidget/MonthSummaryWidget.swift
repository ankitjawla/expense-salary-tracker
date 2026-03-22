import SwiftUI
import WidgetKit

private enum SnapshotKeys {
    static let appGroup = "group.com.example.expensesalarytracker"
    static let monthSnapshot = "month_snapshot_v1"
}

struct MonthPayload {
    let income: Double
    let expense: Double
    let currency: String
    let month: String

    static func load() -> MonthPayload {
        guard let defaults = UserDefaults(suiteName: SnapshotKeys.appGroup),
              let data = defaults.data(forKey: SnapshotKeys.monthSnapshot),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return MonthPayload(income: 0, expense: 0, currency: "USD", month: "This month")
        }
        return MonthPayload(
            income: obj["income"] as? Double ?? 0,
            expense: obj["expense"] as? Double ?? 0,
            currency: obj["currency"] as? String ?? "USD",
            month: obj["month"] as? String ?? "This month"
        )
    }
}

private func formatMoney(_ amount: Double, code: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = code
    return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
}

struct MonthEntry: TimelineEntry {
    let date: Date
    let payload: MonthPayload
}

struct MonthSummaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthEntry {
        MonthEntry(
            date: Date(),
            payload: MonthPayload(income: 3_200, expense: 890, currency: "USD", month: "March 2025")
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MonthEntry) -> Void) {
        completion(MonthEntry(date: Date(), payload: MonthPayload.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MonthEntry>) -> Void) {
        let entry = MonthEntry(date: Date(), payload: MonthPayload.load())
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct MonthSummaryWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: MonthEntry

    private var net: Double { entry.payload.income - entry.payload.expense }

    var body: some View {
        switch family {
        case .systemSmall:
            small
        default:
            medium
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.payload.month)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(formatMoney(entry.payload.expense, code: entry.payload.currency))
                .font(.title3.weight(.semibold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("Spent")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.payload.month)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                column(title: "Income", value: formatMoney(entry.payload.income, code: entry.payload.currency), color: .green)
                column(title: "Spent", value: formatMoney(entry.payload.expense, code: entry.payload.currency), color: .orange)
                column(title: "Net", value: formatMoney(net, code: entry.payload.currency), color: net >= 0 ? .primary : .red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func column(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MonthSummaryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.example.expensesalarytracker.monthsummary", provider: MonthSummaryProvider()) { entry in
            MonthSummaryWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("This month")
        .description("Income, spending, and net for the current month.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
