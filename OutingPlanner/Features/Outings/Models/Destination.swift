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
    var time: Date?
    var outing: Outing? // Back-reference ke Outing
    
    // Relasi One-to-Many ke Stop
    @Relationship(deleteRule: .cascade, inverse: \Stops.destination)
    var stops: [Stops] = []
    
    init(id: UUID = UUID(), name: String, purpose: String) {
        self.id = id
        self.name = name
        self.purpose = purpose
    }
}
