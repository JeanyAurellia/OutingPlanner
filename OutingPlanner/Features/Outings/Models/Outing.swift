//
//  Outing.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class Outing {
    @Attribute(.unique) var id: UUID
    var name: String
    var date: Date? // Sudah benar opsional
    var packingListID: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \Destination.outing)
    var destinations: [Destination] = []
    
    @Relationship(deleteRule: .cascade, inverse: \OutingPackingItem.outing)
    var packingItems: [OutingPackingItem] = []
    
    var totalBudget: Int {
        destinations.flatMap { $0.stops }.reduce(0) { $0 + $1.budget }
    }
    
    // PERBAIKAN: Ubah 'date: Date' menjadi 'date: Date? = nil'
    init(id: UUID = UUID(), name: String, date: Date? = nil, packingListID: UUID? = nil) {
        self.id = id
        self.name = name
        self.date = date // Sekarang baris ini aman menerima nilai nil dari preview
        self.packingListID = packingListID
    }
}
