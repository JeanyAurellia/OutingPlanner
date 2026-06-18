//
//  PackingRepository.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class PackingRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Ambil semua master packing list untuk ditampilkan di menu depan Settings
    func fetchAllPackingLists() -> [PackingList] {
        let descriptor = FetchDescriptor<PackingList>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Tambah master packing list baru (Tambah Nama & Ikon)
    func createPackingList(name: String, iconName: String) {
        let newList = PackingList(name: name, iconName: iconName)
        modelContext.insert(newList)
        try? modelContext.save()
    }
    
    // Tambah item ke dalam master packing list tertentu
    func addItem(to list: PackingList, itemName: String) {
        let newItem = PackingItem(name: itemName)
        list.items.append(newItem) // SwiftData otomatis mendeteksi relasi induk-anak
        try? modelContext.save()
    }
    
    // Hapus item dari master packing list
    func deleteItem(_ item: PackingItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}
