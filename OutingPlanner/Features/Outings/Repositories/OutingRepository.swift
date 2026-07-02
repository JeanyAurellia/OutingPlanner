//
//  OutingRepository.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class OutingRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Simpan Outing baru + otomatis copy item template belonging ke dalam trip
    func saveOuting(name: String, date: Date?, selectedTemplateList: BelongingList?) {
        let newOuting = Outing(name: name, date: date, belongingListID: selectedTemplateList?.id)
        modelContext.insert(newOuting)
        
        // Logika UI: Jika user meng-attach belonging list, salin itemnya ke tabel jembatan
        if let template = selectedTemplateList {
            for item in template.items {
                let outingItem = OutingBelongingItem(name: item.name)
                newOuting.belongingItems.append(outingItem) // Otomatis mengaitkan relasinya
            }
        }
        
        try? modelContext.save()
        
        NotificationManager.shared.scheduleOutingReminder(for: newOuting)
    }
    
    // Update nama & tanggal Outing yang sudah ada (dipakai saat Edit Outing)
    func updateOuting(_ outing: Outing, name: String, date: Date?) {
        outing.name = name
        outing.date = date
        try? modelContext.save()
        
        NotificationManager.shared.cancelOutingReminder(for: outing)
        NotificationManager.shared.scheduleOutingReminder(for: outing)
    }
    
    // Hapus Outing beserta seluruh destinasi & stop di dalamnya (cascade otomatis dari SwiftData)
    func deleteOuting(_ outing: Outing) {
        NotificationManager.shared.cancelOutingReminder(for: outing)
        for destination in outing.destinations {
            for stop in destination.stops {
                NotificationManager.shared.cancelStopReminder(for: stop)
            }
        }
        
        modelContext.delete(outing)
        try? modelContext.save()
    }
    
    // Tambah destinasi ke Outing yang sudah ada
    func addDestination(to outing: Outing, name: String, purpose: String) {
        let destination = Destination(name: name, purpose: purpose)
        outing.destinations.append(destination)
        try? modelContext.save()
    }
    
    // Update nama & kategori destinasi yang sudah ada
    func updateDestination(_ destination: Destination, name: String, purpose: String) {
        destination.name = name
        destination.purpose = purpose
        try? modelContext.save()
    }
    
    // Hapus destinasi (beserta semua stop di dalamnya) dari sebuah Outing
    func deleteDestination(_ destination: Destination, from outing: Outing) {
        for stop in destination.stops {
            NotificationManager.shared.cancelStopReminder(for: stop)
        }
        
        outing.destinations.removeAll { $0.id == destination.id }
        modelContext.delete(destination)
        try? modelContext.save()
    }
    
    // Tambah stop baru ke sebuah destinasi
    func addStop(to destination: Destination, name: String, time: Date, location: String, notes: String, budget: Int) {
        let stop = Stops(name: name, time: time, location: location, notes: notes, budget: budget)
        destination.stops.append(stop)
        try? modelContext.save()
        
        NotificationManager.shared.scheduleStopReminder(for: stop)
    }
    
    // Update semua field stop yang sudah ada (dipakai EditStopView)
    func updateStop(_ stop: Stops, name: String, time: Date, location: String, notes: String, budget: Int) {
        stop.name = name
        stop.time = time
        stop.location = location
        stop.notes = notes
        stop.budget = budget
        try? modelContext.save()
        
        NotificationManager.shared.cancelStopReminder(for: stop)
        NotificationManager.shared.scheduleStopReminder(for: stop)
    }
    
    // Hapus stop dari destinasinya
    func deleteStop(_ stop: Stops, from destination: Destination) {
        NotificationManager.shared.cancelStopReminder(for: stop)
        
        destination.stops.removeAll { $0.id == stop.id }
        modelContext.delete(stop)
        try? modelContext.save()
    }
    
    // Toggle status selesai/belum sebuah stop
    func toggleStopChecked(_ stop: Stops) {
        stop.isChecked.toggle()
        try? modelContext.save()
    }
}
