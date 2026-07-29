//
//  OutingRepository.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class OutingRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveOuting(name: String, date: Date?, selectedTemplateList: BelongingList?) {
        let newOuting = Outing(name: name, date: date, belongingListID: selectedTemplateList?.id)
        modelContext.insert(newOuting)

        if let template = selectedTemplateList {
            for item in template.items {
                let outingItem = OutingBelongingItem(name: item.name)
                newOuting.belongingItems.append(outingItem)
            }
        }

        try? modelContext.save()
        rescheduleOutingReminder(for: newOuting)
    }

    func updateOuting(_ outing: Outing, name: String, date: Date?) {
        outing.name = name
        outing.date = date
        try? modelContext.save()

        rescheduleOutingReminder(for: outing)
    }

    func deleteOuting(_ outing: Outing) {
        NotificationManager.shared.cancelOutingReminder(for: outing)
        for destination in outing.destinations {
            NotificationManager.shared.cancelDestinationReminder(for: destination)
        }

        modelContext.delete(outing)
        try? modelContext.save()
    }

    func addDestination(
        to outing: Outing,
        name: String,
        purpose: String,
        time: Date,
        location: String,
        notes: String,
        budget: Int
    ) {
        let destination = Destination(
            name: name,
            purpose: purpose,
            time: time,
            location: location,
            notes: notes,
            budget: budget
        )
        outing.destinations.append(destination)
        try? modelContext.save()

        NotificationManager.shared.scheduleDestinationReminder(for: destination)
        rescheduleOutingReminder(for: outing)
    }

    func updateDestination(
        _ destination: Destination,
        name: String,
        purpose: String,
        time: Date,
        location: String,
        notes: String,
        budget: Int
    ) {
        destination.name = name
        destination.purpose = purpose
        destination.time = time
        destination.location = location
        destination.notes = notes
        destination.budget = budget
        try? modelContext.save()

        NotificationManager.shared.cancelDestinationReminder(for: destination)
        NotificationManager.shared.scheduleDestinationReminder(for: destination)
        if let outing = destination.outing {
            rescheduleOutingReminder(for: outing)
        }
    }

    func deleteDestination(_ destination: Destination, from outing: Outing) {
        NotificationManager.shared.cancelDestinationReminder(for: destination)

        outing.destinations.removeAll { $0.id == destination.id }
        modelContext.delete(destination)
        try? modelContext.save()

        rescheduleOutingReminder(for: outing)
    }

    func toggleDestinationChecked(_ destination: Destination) {
        destination.isChecked.toggle()
        try? modelContext.save()
    }

    private func rescheduleOutingReminder(for outing: Outing) {
        NotificationManager.shared.cancelOutingReminder(for: outing)
        NotificationManager.shared.scheduleOutingReminder(for: outing)
    }
}
