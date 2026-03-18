import Foundation
import UIKit
import WidgetKit

// MARK: - Shared Data Model (must match SubLogicWidget target's definition)

struct SubLogicWidgetData: Codable {
    struct UpcomingItem: Codable, Identifiable {
        let id: String
        let name: String
        let emoji: String
        let colorHex: String
        let daysUntil: Int
        let amountFormatted: String
        let daysLabel: String       // pre-localized: "Bugün" / "3 gün" / "Today" / "in 3d"
        let iconBase64: String?     // JPEG thumbnail for custom photo icons
    }

    let monthlyTotalFormatted: String
    let yearlyTotalFormatted: String
    let activeCount: Int
    let upcoming: [UpcomingItem]
    let lastUpdate: Date

    // Pre-localized labels (generated in main app so widget matches app language)
    let perMonthLabel: String
    let activeLabel: String
    let upcomingLabel: String
    let noUpcomingLabel: String
}

// MARK: - Widget Data Service

enum WidgetDataService {
    static let appGroupID    = "group.com.bkb.SubLogic"
    static let widgetDataKey = "sublogic_widget_data"

    static func write(subscriptions: [Subscription],
                      currencyService: CurrencyService,
                      displayCurrency: String) {
        let active = subscriptions.filter { $0.isActive }

        let monthlyTotal = active.reduce(0.0) { sum, sub in
            sum + currencyService.convert(amount: sub.monthlyAmount,
                                          from: sub.currency,
                                          to: displayCurrency)
        }

        // Localized labels from main app bundle (correct language always)
        let perMonthLabel   = NSLocalizedString("widget.perMonth",    comment: "")
        let upcomingLabel   = NSLocalizedString("widget.upcoming",    comment: "")
        let noUpcomingLabel = NSLocalizedString("widget.noUpcoming",  comment: "")
        let activeLabel     = String(format: NSLocalizedString("widget.activeCount", comment: ""), active.count)

        let upcomingItems = active
            .filter { $0.daysUntilNextBilling <= 30 }
            .sorted { $0.daysUntilNextBilling < $1.daysUntilNextBilling }
            .prefix(5)
            .map { sub -> SubLogicWidgetData.UpcomingItem in
                let converted = currencyService.convert(amount: sub.amount,
                                                        from: sub.currency,
                                                        to: displayCurrency)
                let formatted = currencyService.formatted(amount: converted, currency: displayCurrency)

                // Localized days label
                let daysLabel: String
                if sub.daysUntilNextBilling == 0 {
                    daysLabel = NSLocalizedString("widget.today", comment: "")
                } else {
                    daysLabel = String(format: NSLocalizedString("widget.inDays", comment: ""),
                                       sub.daysUntilNextBilling)
                }

                // Thumbnail for custom photo icons (44×44 px, JPEG 70%)
                var iconBase64: String? = nil
                if let imageData = sub.customImageData,
                   let image = UIImage(data: imageData),
                   let thumb = image.preparingThumbnail(of: CGSize(width: 44, height: 44)),
                   let jpegData = thumb.jpegData(compressionQuality: 0.7) {
                    iconBase64 = jpegData.base64EncodedString()
                }

                return SubLogicWidgetData.UpcomingItem(
                    id: sub.id.uuidString,
                    name: sub.name,
                    emoji: sub.iconEmoji,
                    colorHex: sub.colorHex,
                    daysUntil: sub.daysUntilNextBilling,
                    amountFormatted: formatted,
                    daysLabel: daysLabel,
                    iconBase64: iconBase64
                )
            }

        let data = SubLogicWidgetData(
            monthlyTotalFormatted: currencyService.formatted(amount: monthlyTotal, currency: displayCurrency),
            yearlyTotalFormatted:  currencyService.formatted(amount: monthlyTotal * 12, currency: displayCurrency),
            activeCount:     active.count,
            upcoming:        Array(upcomingItems),
            lastUpdate:      Date(),
            perMonthLabel:   perMonthLabel,
            activeLabel:     activeLabel,
            upcomingLabel:   upcomingLabel,
            noUpcomingLabel: noUpcomingLabel
        )

        guard let defaults = UserDefaults(suiteName: appGroupID),
              let encoded = try? JSONEncoder().encode(data) else { return }

        defaults.set(encoded, forKey: widgetDataKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
