import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    let upcomingKey = "isUpcomingReminderEnabled"
    let stopKey = "isStopReminderEnabled"
    let timeKey = "stopReminderTime"
    
    private override init() {
        super.init()
        UserDefaults.standard.register(defaults: [
            upcomingKey: false,
            stopKey: true,
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
        
        // Trigger in 5 seconds
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
        
        guard let date = outing.date else { return }
        
        // Reminder 1 day before
        guard let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return }
        
        // Pastikan tidak menjadwalkan di masa lalu
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
    
    func scheduleStopReminder(for stop: Stops) {
        let isEnabled = UserDefaults.standard.bool(forKey: stopKey)
        guard isEnabled else { return }
        
        let reminderTime = UserDefaults.standard.integer(forKey: timeKey)
        let minutesBefore = reminderTime > 0 ? reminderTime : 30
        
        // Reminder X minutes before
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: stop.time) else { return }
        
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Stop"
        content.body = "Next stop: \(stop.name) in \(minutesBefore) minutes."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "stop_\(stop.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling stop reminder: \(error)")
            }
        }
    }
    
    func cancelStopReminder(for stop: Stops) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["stop_\(stop.id.uuidString)"])
    }
    
    func refreshAllStopReminders(stops: [Stops]) {
        for stop in stops {
            cancelStopReminder(for: stop)
            scheduleStopReminder(for: stop)
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
    
    func cancelAllStopReminders(stops: [Stops]) {
        let identifiers = stops.map { "stop_\($0.id.uuidString)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
