//
//  PackingItem.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class PackingItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var packingList: PackingList? // Back-reference ke list induk
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
