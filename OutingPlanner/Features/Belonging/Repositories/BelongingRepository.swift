//
//  BelongingRepository.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class BelongingRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Ambil semua master belonging list untuk ditampilkan di menu depan Settings
    func fetchAllBelongingLists() -> [BelongingList] {
        let descriptor = FetchDescriptor<BelongingList>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Tambah master belonging list baru (Tambah Nama & Ikon)
    func createBelongingList(name: String, iconName: String) {
        let newList = BelongingList(name: name, iconName: iconName)
        modelContext.insert(newList)
        try? modelContext.save()
    }
    
    // Tambah item ke dalam master belonging list tertentu
    func addItem(to list: BelongingList, itemName: String) {
        let newItem = BelongingItem(name: itemName)
        list.items.append(newItem) // SwiftData otomatis mendeteksi relasi induk-anak
        try? modelContext.save()
    }
    
    // Hapus item dari master belonging list
    func deleteItem(_ item: BelongingItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}
