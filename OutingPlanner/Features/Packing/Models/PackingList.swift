//
//  PackingList.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class PackingList {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    
    // Relasi ke Master Items: Jika list dihapus, semua item di dalamnya ikut terhapus
    @Relationship(deleteRule: .cascade, inverse: \PackingItem.packingList)
    var items: [PackingItem] = []
    
    init(id: UUID = UUID(), name: String, iconName: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
}
