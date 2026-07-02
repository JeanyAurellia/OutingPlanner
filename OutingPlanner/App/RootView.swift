//
//  RootView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI

enum AppTab {
    case outing
    case calendar
    case settings
}

struct RootView: View {
    @State private var activeTab: AppTab = .outing
    
    var body: some View {
        TabView(selection: $activeTab) {
            
            Tab("Outing", systemImage: "figure.walk", value: .outing) {
                OutingListView()
            }
            
            Tab("Calendar", systemImage: "calendar", value: .calendar) {
                NavigationStack {
                    CalendarView()
                }
            }
            
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tint(.blue)
    }
}

#Preview {
    RootView()
}
