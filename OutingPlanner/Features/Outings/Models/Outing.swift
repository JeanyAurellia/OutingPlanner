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
    var createdAt: Date = Date()
    var belongingListID: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \Destination.outing)
    var destinations: [Destination] = []
    
    @Relationship(deleteRule: .cascade, inverse: \OutingBelongingItem.outing)
    var belongingItems: [OutingBelongingItem] = []
    
    var totalBudget: Int {
        destinations.flatMap { $0.stops }.reduce(0) { $0 + $1.budget }
    }
    
    // PERBAIKAN: Ubah 'date: Date' menjadi 'date: Date? = nil'
    init(id: UUID = UUID(), name: String, date: Date? = nil, createdAt: Date = Date(), belongingListID: UUID? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.createdAt = createdAt
        self.belongingListID = belongingListID
    }
}
