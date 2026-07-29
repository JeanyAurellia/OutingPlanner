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
    var date: Date?
    var createdAt: Date = Date()
    var belongingListID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \Destination.outing)
    var destinations: [Destination] = []

    @Relationship(deleteRule: .cascade, inverse: \OutingBelongingItem.outing)
    var belongingItems: [OutingBelongingItem] = []

    var totalBudget: Int {
        destinations.reduce(0) { $0 + $1.budget }
    }

    var eventStartDate: Date? {
        guard let date, let firstDestination = destinations.sorted(by: { $0.time < $1.time }).first else {
            return date
        }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: firstDestination.time)
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        return calendar.date(from: mergedComponents)
    }

    init(id: UUID = UUID(), name: String, date: Date? = nil, createdAt: Date = Date(), belongingListID: UUID? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.createdAt = createdAt
        self.belongingListID = belongingListID
    }
}
