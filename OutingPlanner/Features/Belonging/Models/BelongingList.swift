//
//  BelongingList.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class BelongingList {
    var id: UUID
    var name: String
    var iconName: String
    
    // Relasi ke Master Items: Jika list dihapus, semua item di dalamnya ikut terhapus
    @Relationship(deleteRule: .cascade, inverse: \BelongingItem.belongingList)
    var items: [BelongingItem] = []
    
    init(id: UUID = UUID(), name: String, iconName: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
}
