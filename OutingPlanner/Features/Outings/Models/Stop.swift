//
//  Stop.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class Stops {
    @Attribute(.unique) var id: UUID
    var name: String
    var time: Date // Menggunakan Date, nanti diformat jadi Jam di UI menggunakan Helper/Formatter
    var location: String
    var notes: String
    var budget: Int
    var isChecked: Bool = false // Status selesai/belum, ditampilkan sebagai checkmark di Detail Outing
    var destination: Destination? // Back-reference ke Destination
    
    init(id: UUID = UUID(), name: String, time: Date, location: String, notes: String, budget: Int, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.time = time
        self.location = location
        self.notes = notes
        self.budget = budget
        self.isChecked = isChecked
    }
}
