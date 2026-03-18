import Foundation
import UserNotifications

// MARK: - Notification Service
final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleReminder(for subscription: Subscription) {
        let center = UNUserNotificationCenter.current()
        let baseID = subscription.id.uuidString

        // Remove existing notifications for this subscription
        center.removePendingNotificationRequests(withIdentifiers: [
            "sub_reminder_\(baseID)",
            "sub_day_\(baseID)"
        ])

        // Days-before reminder
        if subscription.reminderDaysBefore > 0 {
            let reminderDate = Calendar.current.date(
                byAdding: .day,
                value: -subscription.reminderDaysBefore,
                to: subscription.nextBillingDate
            ) ?? subscription.nextBillingDate

            if reminderDate > Date() {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
                components.hour = 9
                components.minute = 0

                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("notification.reminder.title", comment: "")
                content.body = String(
                    format: NSLocalizedString("notification.reminder.body", comment: ""),
                    subscription.name,
                    subscription.reminderDaysBefore
                )
                content.sound = .default
                content.badge = 1

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: "sub_reminder_\(baseID)", content: content, trigger: trigger)
                center.add(request)
            }
        }

        // Payment day reminder
        if subscription.remindOnPaymentDay && subscription.nextBillingDate > Date() {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: subscription.nextBillingDate)
            components.hour = 9
            components.minute = 0

            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification.day.title", comment: "")
            content.body = String(
                format: NSLocalizedString("notification.day.body", comment: ""),
                subscription.name
            )
            content.sound = .default
            content.badge = 1

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "sub_day_\(baseID)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    func cancelReminder(for subscriptionID: UUID) {
        let baseID = subscriptionID.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "sub_reminder_\(baseID)",
            "sub_day_\(baseID)"
        ])
    }

    func rescheduleAll(subscriptions: [Subscription]) {
        for sub in subscriptions where sub.isActive {
            scheduleReminder(for: sub)
        }
    }
}
