import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var outings: [Outing]
    @Query private var stops: [Stops]
    
    @AppStorage("isUpcomingReminderEnabled") private var upcomingReminder: Bool = false
    @AppStorage("isStopReminderEnabled") private var stopReminder: Bool = true
    @AppStorage("stopReminderTime") private var stopReminderTime: Int = 30
    
    var body: some View {
        List {
            Section(header: Text("NOTIFICATIONS").foregroundColor(.secondary)) {
                Toggle(isOn: $upcomingReminder) {
                    HStack(spacing: 16) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upcoming Event Reminder")
                                .font(.body.weight(.medium))
                            Text("Notify 1 day before an outing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
                .onChange(of: upcomingReminder) { _, newValue in
                    Task {
                        if newValue {
                            let granted = await NotificationManager.shared.requestAuthorization()
                            if granted {
                                NotificationManager.shared.refreshAllOutingReminders(outings: outings)
                            } else {
                                upcomingReminder = false
                            }
                        } else {
                            NotificationManager.shared.cancelAllOutingReminders(outings: outings)
                        }
                    }
                }
                
                Toggle(isOn: $stopReminder) {
                    HStack(spacing: 16) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stop Reminder")
                                .font(.body.weight(.medium))
                            Text("Notify before each stop")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
                .onChange(of: stopReminder) { _, newValue in
                    Task {
                        if newValue {
                            let granted = await NotificationManager.shared.requestAuthorization()
                            if granted {
                                NotificationManager.shared.refreshAllStopReminders(stops: stops)
                            } else {
                                stopReminder = false
                            }
                        } else {
                            NotificationManager.shared.cancelAllStopReminders(stops: stops)
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(width: 24)
                    
                    Text("Stop Reminder Time")
                        .font(.body.weight(.medium))
                    
                    Spacer()
                    
                    Picker("", selection: $stopReminderTime) {
                        Text("5 Minutes").tag(5)
                        Text("10 Minutes").tag(10)
                        Text("15 Minutes").tag(15)
                        Text("30 Minutes").tag(30)
                        Text("1 Hour").tag(60)
                        Text("2 Hours").tag(120)
                    }
                    .tint(.secondary)
                }
                .padding(.vertical, 4)
                .onChange(of: stopReminderTime) { _, newValue in
                    if stopReminder {
                        NotificationManager.shared.refreshAllStopReminders(stops: stops)
                    }
                }
            }
            
            Section(header: Text("DEFAULT BELONGING LIST").foregroundColor(.secondary)) {
                NavigationLink(destination: BelongingListView()) {
                    HStack(spacing: 16) {
                        Image(systemName: "bag")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Belonging Lists")
                                .font(.body.weight(.medium))
                            Text("Manage reusable belonging lists")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        let granted = await NotificationManager.shared.requestAuthorization()
                        if granted {
                            NotificationManager.shared.testNotification()
                        }
                    }
                } label: {
                    Image(systemName: "bell.badge")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
