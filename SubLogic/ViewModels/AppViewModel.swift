import Foundation
import SwiftUI
import SwiftData
import RevenueCat

// MARK: - App Settings Keys
private enum SettingsKey {
    static let displayCurrency   = "display_currency"
    static let appearanceMode    = "appearance_mode"
    static let appLanguage       = "app_language"
    static let isPremium         = "is_premium"
    static let notificationsOn   = "notifications_enabled"
    static let faceIDEnabled     = "face_id_enabled"
    static let iCloudSync        = "icloud_sync"
    static let onboardingDone    = "onboarding_done"
}

// MARK: - Appearance Mode
enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var localizedName: String {
        switch self {
        case .system: return NSLocalizedString("appearance.system", comment: "")
        case .light:  return NSLocalizedString("appearance.light", comment: "")
        case .dark:   return NSLocalizedString("appearance.dark", comment: "")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - App View Model
@Observable
final class AppViewModel {

    // MARK: - Settings (persisted)
    var displayCurrency: String = UserDefaults.standard.string(forKey: SettingsKey.displayCurrency) ?? "USD" {
        didSet { UserDefaults.standard.set(displayCurrency, forKey: SettingsKey.displayCurrency) }
    }

    var appearanceMode: AppearanceMode = {
        AppearanceMode(rawValue: UserDefaults.standard.string(forKey: SettingsKey.appearanceMode) ?? "") ?? .system
    }() {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: SettingsKey.appearanceMode) }
    }

    var isPremium: Bool = UserDefaults.standard.bool(forKey: SettingsKey.isPremium) {
        didSet { UserDefaults.standard.set(isPremium, forKey: SettingsKey.isPremium) }
    }

    var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: SettingsKey.notificationsOn) {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: SettingsKey.notificationsOn) }
    }

    var faceIDEnabled: Bool = UserDefaults.standard.bool(forKey: SettingsKey.faceIDEnabled) {
        didSet { UserDefaults.standard.set(faceIDEnabled, forKey: SettingsKey.faceIDEnabled) }
    }

    var iCloudSyncEnabled: Bool = UserDefaults.standard.bool(forKey: SettingsKey.iCloudSync) {
        didSet { UserDefaults.standard.set(iCloudSyncEnabled, forKey: SettingsKey.iCloudSync) }
    }

    var onboardingDone: Bool = UserDefaults.standard.bool(forKey: SettingsKey.onboardingDone) {
        didSet { UserDefaults.standard.set(onboardingDone, forKey: SettingsKey.onboardingDone) }
    }

    // MARK: - Free Tier Limit
    static let freeTierLimit = 3

    var canAddMoreSubscriptions: Bool {
        isPremium || currentSubscriptionCount < AppViewModel.freeTierLimit
    }
    var currentSubscriptionCount: Int = 0

    // MARK: - Currency Service
    let currencyService = CurrencyService()

    // MARK: - Navigation
    var selectedTab: Int = 0
    var showPremiumPaywall: Bool = false
    var showAddSubscription: Bool = false

    // MARK: - Init
    init() {
        Task {
            await currencyService.fetchRatesIfNeeded()
        }
    }

    // MARK: - Computed Dashboard Values
    func totalMonthlySpend(subscriptions: [Subscription]) -> Double {
        subscriptions
            .filter { $0.isActive }
            .reduce(0) { total, sub in
                total + currencyService.convert(
                    amount: sub.monthlyAmount,
                    from: sub.currency,
                    to: displayCurrency
                )
            }
    }

    func totalYearlySpend(subscriptions: [Subscription]) -> Double {
        subscriptions
            .filter { $0.isActive }
            .reduce(0) { total, sub in
                total + currencyService.convert(
                    amount: sub.yearlyAmount,
                    from: sub.currency,
                    to: displayCurrency
                )
            }
    }

    func upcomingPayments(subscriptions: [Subscription], days: Int = 30) -> [Subscription] {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return subscriptions
            .filter { $0.isActive && $0.nextBillingDate <= cutoff }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
    }

    // MARK: - Category Breakdown
    struct CategoryBreakdown: Identifiable {
        let id = UUID()
        let category: SubscriptionCategory
        let amount: Double
        let percentage: Double
        let count: Int
    }

    func categoryBreakdown(subscriptions: [Subscription]) -> [CategoryBreakdown] {
        let active = subscriptions.filter { $0.isActive }
        let total = totalMonthlySpend(subscriptions: active)
        guard total > 0 else { return [] }

        var grouped: [SubscriptionCategory: (Double, Int)] = [:]
        for sub in active {
            let converted = currencyService.convert(
                amount: sub.monthlyAmount,
                from: sub.currency,
                to: displayCurrency
            )
            let current = grouped[sub.category] ?? (0, 0)
            grouped[sub.category] = (current.0 + converted, current.1 + 1)
        }

        return grouped
            .map { CategoryBreakdown(
                category: $0.key,
                amount: $0.value.0,
                percentage: ($0.value.0 / total) * 100,
                count: $0.value.1
            )}
            .sorted { $0.amount > $1.amount }
    }

    // MARK: - Formatting
    func formatted(_ amount: Double) -> String {
        currencyService.formatted(amount: amount, currency: displayCurrency)
    }

    func formattedIn(amount: Double, fromCurrency: String) -> String {
        let converted = currencyService.convert(amount: amount, from: fromCurrency, to: displayCurrency)
        return formatted(converted)
    }

    // MARK: - Billing Date Advancement
    func advanceStaleBillingDates(_ subscriptions: [Subscription]) {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        for sub in subscriptions where sub.isActive && sub.nextBillingDate < startOfToday {
            sub.advanceNextBillingDate()
            if sub.trackRemainingPeriods && sub.remainingPeriods > 0 {
                sub.remainingPeriods -= 1
                if sub.remainingPeriods == 0 { sub.isActive = false }
            }
            if notificationsEnabled {
                NotificationService.shared.scheduleReminder(for: sub)
            }
        }
    }

    // MARK: - Statistics Helpers
    struct CycleBreakdown: Identifiable {
        let id = UUID()
        let cycle: BillingCycle
        let monthlyAmount: Double
        let count: Int
    }

    func cycleBreakdown(subscriptions: [Subscription]) -> [CycleBreakdown] {
        let active = subscriptions.filter { $0.isActive }
        var grouped: [BillingCycle: (Double, Int)] = [:]
        for sub in active {
            let monthly = currencyService.convert(amount: sub.monthlyAmount, from: sub.currency, to: displayCurrency)
            let current = grouped[sub.billingCycle] ?? (0, 0)
            grouped[sub.billingCycle] = (current.0 + monthly, current.1 + 1)
        }
        return grouped
            .map { CycleBreakdown(cycle: $0.key, monthlyAmount: $0.value.0, count: $0.value.1) }
            .sorted { $0.monthlyAmount > $1.monthlyAmount }
    }

    func projectedSpend(subscriptions: [Subscription], days: Int) -> Double {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return subscriptions
            .filter { $0.isActive && $0.nextBillingDate <= cutoff }
            .reduce(0) { total, sub in
                total + currencyService.convert(amount: sub.amount, from: sub.currency, to: displayCurrency)
            }
    }

    // MARK: - Notifications
    func scheduleAllReminders(subscriptions: [Subscription]) {
        guard notificationsEnabled else { return }
        NotificationService.shared.rescheduleAll(subscriptions: subscriptions)
    }

    // MARK: - RevenueCat Premium
    func refreshPremiumStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements["SubLogic Pro"]?.isActive == true
        } catch {
            // Keep existing persisted value if fetch fails (e.g. no network)
        }
    }
}
