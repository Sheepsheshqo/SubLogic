import WidgetKit
import SwiftUI

// MARK: - Shared Data Model

struct SubLogicWidgetData: Codable {
    struct UpcomingItem: Codable, Identifiable {
        let id: String
        let name: String
        let emoji: String
        let colorHex: String
        let daysUntil: Int
        let amountFormatted: String
        let daysLabel: String
        let iconBase64: String?
    }
    let monthlyTotalFormatted: String
    let yearlyTotalFormatted: String
    let activeCount: Int
    let upcoming: [UpcomingItem]
    let lastUpdate: Date
    let perMonthLabel: String
    let activeLabel: String
    let upcomingLabel: String
    let noUpcomingLabel: String

    static var placeholder: SubLogicWidgetData {
        SubLogicWidgetData(
            monthlyTotalFormatted: "$47.99", yearlyTotalFormatted: "$575.88",
            activeCount: 5,
            upcoming: [
                UpcomingItem(id: "1", name: "Netflix",   emoji: "📺", colorHex: "E50914", daysUntil: 0,  amountFormatted: "$15.99", daysLabel: "Bugün",  iconBase64: nil),
                UpcomingItem(id: "2", name: "Spotify",   emoji: "🎵", colorHex: "1DB954", daysUntil: 4,  amountFormatted: "$9.99",  daysLabel: "4 gün",  iconBase64: nil),
                UpcomingItem(id: "3", name: "iCloud+",   emoji: "☁️", colorHex: "4A9EFF", daysUntil: 14, amountFormatted: "$2.99",  daysLabel: "14 gün", iconBase64: nil),
            ],
            lastUpdate: Date(),
            perMonthLabel: "aylık", activeLabel: "5 aktif",
            upcomingLabel: "YAKLAŞAN", noUpcomingLabel: "Yaklaşan ödeme\nyok 🎉"
        )
    }
}

// MARK: - Provider

struct SubLogicProvider: TimelineProvider {
    typealias Entry = SubLogicEntry
    private let appGroupID    = "group.com.bkb.SubLogic"
    private let widgetDataKey = "sublogic_widget_data"

    func placeholder(in context: Context) -> SubLogicEntry { SubLogicEntry(date: Date(), data: .placeholder) }
    func getSnapshot(in context: Context, completion: @escaping (SubLogicEntry) -> Void) { completion(SubLogicEntry(date: Date(), data: load())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SubLogicEntry>) -> Void) {
        let entry = SubLogicEntry(date: Date(), data: load())
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
    private func load() -> SubLogicWidgetData {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let raw  = defaults.data(forKey: widgetDataKey),
              let data = try? JSONDecoder().decode(SubLogicWidgetData.self, from: raw)
        else { return .placeholder }
        return data
    }
}

struct SubLogicEntry: TimelineEntry {
    let date: Date
    let data: SubLogicWidgetData
}

// MARK: - Icon Helper

struct WIcon: View {
    let item: SubLogicWidgetData.UpcomingItem
    let size: CGFloat
    var body: some View {
        Group {
            if let b64 = item.iconBase64, let d = Data(base64Encoded: b64), let img = UIImage(data: d) {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.26))
            } else {
                Text(item.emoji)
                    .font(.system(size: size * 0.58))
                    .frame(width: size, height: size)
                    .background(WColor(item.colorHex).opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.26))
            }
        }
    }
}

// MARK: - Urgency

private func WColor(_ hex: String) -> Color { Color(hex: hex) }

private func urgencyColor(_ item: SubLogicWidgetData.UpcomingItem) -> Color {
    item.daysUntil == 0 ? Color(hex: "FF453A") :
    item.daysUntil <= 3 ? Color(hex: "FF9F0A") :
    Color(hex: item.colorHex)
}
private func isHot(_ item: SubLogicWidgetData.UpcomingItem) -> Bool { item.daysUntil <= 3 }

// ============================================================
// MARK: - STYLE 1: Dark
// ============================================================

struct DarkWidget: View {
    let data: SubLogicWidgetData
    let isSmall: Bool

    private var items: ArraySlice<SubLogicWidgetData.UpcomingItem> {
        data.upcoming.prefix(isSmall ? 2 : 3)
    }

    var body: some View {
        ZStack {
            Color(hex: "0D0D11")
            VStack(alignment: .leading, spacing: 0) {
                header
                Spacer().frame(height: 9)
                if data.upcoming.isEmpty {
                    emptyView(dark: true)
                } else {
                    rows
                }
                Spacer(minLength: 0)
            }
            .padding(13)
        }
    }

    private var header: some View {
        HStack(spacing: 5) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "4A9EFF"))
            Text(data.upcomingLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "4A9EFF"))
                .tracking(0.7)
            Spacer()
            Text(data.activeLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
        }
    }

    private var rows: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                darkRow(item)
                if idx < items.count - 1 {
                    Color.white.opacity(0.06).frame(height: 1).padding(.vertical, 5).padding(.leading, 14)
                }
            }
        }
    }

    private func darkRow(_ item: SubLogicWidgetData.UpcomingItem) -> some View {
        let col = urgencyColor(item)
        let hot = isHot(item)
        return HStack(spacing: 9) {
            Capsule().fill(col).frame(width: 3, height: 26)
            WIcon(item: item, size: 26)
            Text(item.name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(item.amountFormatted)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(item.daysLabel)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(hot ? col : .white.opacity(0.35))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background((hot ? col : Color.white).opacity(hot ? 0.14 : 0.07))
                .clipShape(Capsule())
        }
    }
}

// ============================================================
// MARK: - STYLE 2: Vivid
// ============================================================

struct VividWidget: View {
    let data: SubLogicWidgetData
    let isSmall: Bool

    private var items: ArraySlice<SubLogicWidgetData.UpcomingItem> {
        data.upcoming.prefix(isSmall ? 2 : 3)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "18082E"), Color(hex: "0B1628")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            // Soft glowing blobs — small, no overflow
            Ellipse()
                .fill(Color(hex: "BF5AF2").opacity(0.22))
                .frame(width: 70, height: 50)
                .blur(radius: 22)
                .offset(x: -55, y: -50)
            Ellipse()
                .fill(Color(hex: "4A9EFF").opacity(0.18))
                .frame(width: 60, height: 45)
                .blur(radius: 18)
                .offset(x: isSmall ? 55 : 130, y: 50)

            VStack(alignment: .leading, spacing: 0) {
                vividHeader
                Spacer().frame(height: 9)
                if data.upcoming.isEmpty {
                    emptyView(dark: true)
                } else {
                    VStack(spacing: 5) {
                        ForEach(items) { item in vividRow(item) }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(13)
        }
    }

    private var vividHeader: some View {
        HStack(spacing: 5) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "BF5AF2"))
            Text(data.upcomingLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "BF5AF2"))
                .tracking(0.7)
            Spacer()
            Text(data.activeLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "BF5AF2").opacity(0.55))
        }
    }

    private func vividRow(_ item: SubLogicWidgetData.UpcomingItem) -> some View {
        let col = urgencyColor(item)
        let hot = isHot(item)
        return HStack(spacing: 9) {
            WIcon(item: item, size: 26)
            Text(item.name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(item.amountFormatted)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(item.daysLabel)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(hot ? col : .white.opacity(0.55))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(col.opacity(hot ? 0.2 : 0.06))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(Color(hex: item.colorHex).opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(hex: item.colorHex).opacity(0.18), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

// ============================================================
// MARK: - STYLE 3: Minimal (adaptive)
// ============================================================

struct MinimalWidget: View {
    let data: SubLogicWidgetData
    let isSmall: Bool

    private var items: ArraySlice<SubLogicWidgetData.UpcomingItem> {
        data.upcoming.prefix(isSmall ? 2 : 3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            minimalHeader
            Spacer().frame(height: 9)
            if data.upcoming.isEmpty {
                emptyView(dark: false)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                        minimalRow(item)
                        if idx < items.count - 1 {
                            Divider().padding(.leading, 36).padding(.vertical, 5)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(13)
    }

    private var minimalHeader: some View {
        HStack(spacing: 5) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "4A9EFF"))
            Text(data.upcomingLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "4A9EFF"))
                .tracking(0.7)
            Spacer()
            Text(data.activeLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private func minimalRow(_ item: SubLogicWidgetData.UpcomingItem) -> some View {
        let col = urgencyColor(item)
        let hot = isHot(item)
        return HStack(spacing: 9) {
            WIcon(item: item, size: 26)
            Text(item.name)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(item.amountFormatted)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "4A9EFF"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(item.daysLabel)
                .font(.system(size: 9, weight: hot ? .semibold : .regular, design: .rounded))
                .foregroundColor(hot ? col : .secondary)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(col.opacity(hot ? 0.12 : 0))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Lock Screen

struct AccessoryWidget: View {
    let data: SubLogicWidgetData
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock").font(.system(size: 12))
            VStack(alignment: .leading, spacing: 1) {
                if let first = data.upcoming.first {
                    Text(first.name).font(.system(size: 12, weight: .semibold, design: .rounded))
                    Text("\(first.amountFormatted) · \(first.daysLabel)")
                        .font(.system(size: 10, design: .rounded)).foregroundColor(.secondary)
                } else {
                    Text(data.noUpcomingLabel).font(.system(size: 11, design: .rounded))
                }
            }
            Spacer()
        }
    }
}

// MARK: - Empty state helper

private func emptyView(dark: Bool) -> some View {
    Text("🎉")
        .font(.system(size: 28))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

// ============================================================
// MARK: - Entry Views
// ============================================================

struct DarkEntryView: View {
    var entry: SubLogicEntry
    @Environment(\.widgetFamily) var family
    var body: some View {
        DarkWidget(data: entry.data, isSmall: family == .systemSmall)
    }
}

struct VividEntryView: View {
    var entry: SubLogicEntry
    @Environment(\.widgetFamily) var family
    var body: some View {
        VividWidget(data: entry.data, isSmall: family == .systemSmall)
    }
}

struct MinimalEntryView: View {
    var entry: SubLogicEntry
    @Environment(\.widgetFamily) var family
    var body: some View {
        switch family {
        case .accessoryRectangular: AccessoryWidget(data: entry.data)
        default: MinimalWidget(data: entry.data, isSmall: family == .systemSmall)
        }
    }
}

// ============================================================
// MARK: - Widget Declarations
// ============================================================

struct SubLogicWidgetClassic: Widget {
    let kind = "SubLogicWidgetClassic"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubLogicProvider()) { entry in
            DarkEntryView(entry: entry)
                .containerBackground(Color(hex: "0D0D11"), for: .widget)
        }
        .configurationDisplayName("SubLogic · Dark")
        .description("Upcoming payments on a sleek dark background.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SubLogicWidgetVivid: Widget {
    let kind = "SubLogicWidgetVivid"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubLogicProvider()) { entry in
            VividEntryView(entry: entry)
                .containerBackground(Color(hex: "0B1628"), for: .widget)
        }
        .configurationDisplayName("SubLogic · Vivid")
        .description("Upcoming payments with a gradient and frosted cards.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SubLogicWidgetMinimal: Widget {
    let kind = "SubLogicWidgetMinimal"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubLogicProvider()) { entry in
            MinimalEntryView(entry: entry)
                .containerBackground(Color(UIColor.systemBackground), for: .widget)
        }
        .configurationDisplayName("SubLogic · Minimal")
        .description("Clean upcoming payments, adapts to light and dark mode.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

// MARK: - Color(hex:)

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Previews

#Preview("Dark Small",   as: .systemSmall)  { SubLogicWidgetClassic() } timeline: { SubLogicEntry(date: .now, data: .placeholder) }
#Preview("Dark Medium",  as: .systemMedium) { SubLogicWidgetClassic() } timeline: { SubLogicEntry(date: .now, data: .placeholder) }
#Preview("Vivid Small",  as: .systemSmall)  { SubLogicWidgetVivid()   } timeline: { SubLogicEntry(date: .now, data: .placeholder) }
#Preview("Vivid Medium", as: .systemMedium) { SubLogicWidgetVivid()   } timeline: { SubLogicEntry(date: .now, data: .placeholder) }
#Preview("Min Small",    as: .systemSmall)  { SubLogicWidgetMinimal() } timeline: { SubLogicEntry(date: .now, data: .placeholder) }
#Preview("Min Medium",   as: .systemMedium) { SubLogicWidgetMinimal() } timeline: { SubLogicEntry(date: .now, data: .placeholder) }
