//
//  OutingPackingItem.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class OutingPackingItem {
    @Attribute(.unique) var id: UUID
    var name: String     // Menyimpan salinan nama dari template asli
    var isChecked: Bool  // Status centang khusus untuk trip ini
    var outing: Outing?  // Back-reference ke Outing terkait
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
    }
}
