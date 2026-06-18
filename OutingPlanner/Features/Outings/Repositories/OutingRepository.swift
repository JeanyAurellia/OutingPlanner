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
    
    // Simpan Outing baru + otomatis copy item template packing ke dalam trip
    func saveOuting(name: String, date: Date, selectedTemplateList: PackingList?) {
        let newOuting = Outing(name: name, date: date, packingListID: selectedTemplateList?.id)
        modelContext.insert(newOuting)
        
        // Logika UI: Jika user meng-attach packing list, salin itemnya ke tabel jembatan
        if let templateList = selectedTemplateList {
            for item in templateList.items {
                let outingItem = OutingPackingItem(name: item.name)
                newOuting.packingItems.append(outingItem) // Otomatis mengaitkan relasinya
            }
        }
        
        try? modelContext.save()
    }
    
    // Tambah destinasi ke Outing yang sudah ada
    func addDestination(to outing: Outing, name: String, category: String) {
        let destination = Destination(name: name, category: category)
        outing.destinations.append(destination)
        try? modelContext.save()
    }
    
    // Tambah stop baru ke sebuah destinasi
    func addStop(to destination: Destination, name: String, time: Date, location: String, notes: String, budget: Int) {
        let stop = Stops(name: name, time: time, location: location, notes: notes, budget: budget)
        destination.stops.append(stop)
        try? modelContext.save()
    }
    
    // Update semua field stop yang sudah ada (dipakai EditStopView nanti)
    func updateStop(_ stop: Stops, name: String, time: Date, location: String, notes: String, budget: Int) {
        stop.name = name
        stop.time = time
        stop.location = location
        stop.notes = notes
        stop.budget = budget
        try? modelContext.save()
    }
    
    // Hapus stop dari destinasinya
    func deleteStop(_ stop: Stops, from destination: Destination) {
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
