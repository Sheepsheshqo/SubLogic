import Foundation
import SwiftData

@Model
final class Subscription {
    var id: UUID = UUID()
    var name: String = ""
    var amount: Double = 0.0
    var currency: String = "USD"
    var billingCycleRaw: String = BillingCycle.monthly.rawValue
    var categoryRaw: String = SubscriptionCategory.other.rawValue
    var startDate: Date = Date()
    var nextBillingDate: Date = Date()
    var colorHex: String = "4A9EFF"
    var iconEmoji: String = "📦"
    var serviceTemplateID: String? = nil
    var notes: String = ""
    var isActive: Bool = true
    var reminderDaysBefore: Int = 3
    var remindOnPaymentDay: Bool = false
    var websiteURL: String = ""
    var trackRemainingPeriods: Bool = false
    var remainingPeriods: Int = 0
    var createdAt: Date = Date()
    @Attribute(.externalStorage) var customImageData: Data? = nil

    // Computed from raw strings to avoid SwiftData enum issues
    var billingCycle: BillingCycle {
        get { BillingCycle(rawValue: billingCycleRaw) ?? .monthly }
        set { billingCycleRaw = newValue.rawValue }
    }

    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        name: String,
        amount: Double,
        currency: String = "USD",
        billingCycle: BillingCycle = .monthly,
        category: SubscriptionCategory = .other,
        startDate: Date = Date(),
        colorHex: String = "4A9EFF",
        iconEmoji: String = "📦",
        serviceTemplateID: String? = nil,
        notes: String = "",
        reminderDaysBefore: Int = 3,
        remindOnPaymentDay: Bool = false,
        websiteURL: String = "",
        trackRemainingPeriods: Bool = false,
        remainingPeriods: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.currency = currency
        self.billingCycleRaw = billingCycle.rawValue
        self.categoryRaw = category.rawValue
        self.startDate = startDate
        self.nextBillingDate = Subscription.computeNextBillingDate(from: startDate, cycle: billingCycle)
        self.colorHex = colorHex
        self.iconEmoji = iconEmoji
        self.serviceTemplateID = serviceTemplateID
        self.notes = notes
        self.reminderDaysBefore = reminderDaysBefore
        self.remindOnPaymentDay = remindOnPaymentDay
        self.websiteURL = websiteURL
        self.trackRemainingPeriods = trackRemainingPeriods
        self.remainingPeriods = remainingPeriods
        self.isActive = true
        self.createdAt = Date()
    }

    // MARK: - Helpers

    static func computeNextBillingDate(from date: Date, cycle: BillingCycle) -> Date {
        let calendar = Calendar.current
        let now = Date()
        var next = date
        while next <= now {
            switch cycle {
            case .weekly:    next = calendar.date(byAdding: .weekOfYear, value: 1, to: next) ?? next
            case .monthly:   next = calendar.date(byAdding: .month, value: 1, to: next) ?? next
            case .quarterly: next = calendar.date(byAdding: .month, value: 3, to: next) ?? next
            case .yearly:    next = calendar.date(byAdding: .year, value: 1, to: next) ?? next
            }
        }
        return next
    }

    var monthlyAmount: Double {
        amount * billingCycle.monthlyMultiplier
    }

    var yearlyAmount: Double {
        switch billingCycle {
        case .yearly:    return amount
        case .monthly:   return amount * 12
        case .quarterly: return amount * 4
        case .weekly:    return amount * 52
        }
    }

    var daysUntilNextBilling: Int {
        let calendar = Calendar.current
        let comps = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: nextBillingDate)
        )
        return max(0, comps.day ?? 0)
    }

    func advanceNextBillingDate() {
        nextBillingDate = Subscription.computeNextBillingDate(from: nextBillingDate, cycle: billingCycle)
    }
}
