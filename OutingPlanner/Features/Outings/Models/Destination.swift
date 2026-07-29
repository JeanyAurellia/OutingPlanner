//
//  Destination.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@Model
final class Destination {
    @Attribute(.unique) var id: UUID
    var name: String
    var purpose: String
    var time: Date
    var location: String
    var notes: String
    var budget: Int
    var isChecked: Bool
    var outing: Outing?

    init(
        id: UUID = UUID(),
        name: String,
        purpose: String,
        time: Date = Date(),
        location: String = "",
        notes: String = "",
        budget: Int = 0,
        isChecked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.purpose = purpose
        self.time = time
        self.location = location
        self.notes = notes
        self.budget = budget
        self.isChecked = isChecked
    }
}
