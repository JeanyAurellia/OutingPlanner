import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    let upcomingKey = "isUpcomingReminderEnabled"
    let destinationKey = "isDestinationReminderEnabled"
    let timeKey = "destinationReminderTime"

    private override init() {
        super.init()
        UserDefaults.standard.register(defaults: [
            upcomingKey: false,
            destinationKey: true,
            timeKey: 30
        ])
        UNUserNotificationCenter.current().delegate = self
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a simulated notification that fires in 5 seconds!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_sim", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error)")
            } else {
                print("Test notification scheduled.")
            }
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    func scheduleOutingReminder(for outing: Outing) {
        let isEnabled = UserDefaults.standard.bool(forKey: upcomingKey)
        guard isEnabled else { return }
        guard let reminderDate = outingReminderDate(for: outing) else { return }
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Outing"
        content.body = "Your outing '\(outing.name)' starts tomorrow."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "outing_\(outing.id.uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling outing reminder: \(error)")
            }
        }
    }

    func cancelOutingReminder(for outing: Outing) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["outing_\(outing.id.uuidString)"])
    }

    func scheduleDestinationReminder(for destination: Destination) {
        let isEnabled = UserDefaults.standard.bool(forKey: destinationKey)
        guard isEnabled else { return }

        let reminderTime = UserDefaults.standard.integer(forKey: timeKey)
        let minutesBefore = reminderTime > 0 ? reminderTime : 30
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: destination.time) else { return }
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Destination"
        content.body = "Next destination: \(destination.name) in \(minutesBefore) minutes."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "destination_\(destination.id.uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling destination reminder: \(error)")
            }
        }
    }

    func cancelDestinationReminder(for destination: Destination) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["destination_\(destination.id.uuidString)"])
    }

    func refreshAllDestinationReminders(destinations: [Destination]) {
        for destination in destinations {
            cancelDestinationReminder(for: destination)
            scheduleDestinationReminder(for: destination)
        }
    }

    func refreshAllOutingReminders(outings: [Outing]) {
        for outing in outings {
            cancelOutingReminder(for: outing)
            scheduleOutingReminder(for: outing)
        }
    }

    func cancelAllOutingReminders(outings: [Outing]) {
        let identifiers = outings.map { "outing_\($0.id.uuidString)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAllDestinationReminders(destinations: [Destination]) {
        let identifiers = destinations.map { "destination_\($0.id.uuidString)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func outingReminderDate(for outing: Outing) -> Date? {
        guard let eventStartDate = outing.eventStartDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: -1, to: eventStartDate)
    }
}
