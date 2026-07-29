//
//  OutingPlannerApp.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 17/06/26.
//

import SwiftUI
import SwiftData

@main
struct OutingPlannerApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Outing.self, Destination.self, BelongingList.self, BelongingItem.self, OutingBelongingItem.self])
        do {
            container = try ModelContainer(for: schema, configurations: [])
        } catch {
            print("Skema SwiftData berubah! Menghapus database lama...")
            let config = ModelConfiguration(schema: schema)
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("store-shm"))
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("store-wal"))
            do {
                container = try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Gagal menginisialisasi ulang SwiftData Container: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
