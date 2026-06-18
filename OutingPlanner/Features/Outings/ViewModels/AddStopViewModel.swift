//
//  AddStopViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//


//
//  AddStopViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class AddStopViewModel: ObservableObject {
    @Published var stopName: String
    @Published var location: String
    @Published var budgetText: String
    @Published var notes: String
    @Published var selectedTime: Date

    let destination: Destination
    private let existingStop: Stops?

    var isEditMode: Bool { existingStop != nil }
    var navigationTitle: String { isEditMode ? "Edit Stop" : "Add Stop" }
    var isSaveDisabled: Bool { stopName.trimmingCharacters(in: .whitespaces).isEmpty }

    init(destination: Destination, existingStop: Stops? = nil) {
        self.destination = destination
        self.existingStop = existingStop
        self.stopName = existingStop?.name ?? ""
        self.location = existingStop?.location ?? ""
        self.budgetText = existingStop.map { String($0.budget) } ?? ""
        self.notes = existingStop?.notes ?? ""
        self.selectedTime = existingStop?.time ?? Date()
    }

    func save(modelContext: ModelContext) {
        let budgetValue = Int(budgetText.filter(\.isNumber)) ?? 0
        let repository = OutingRepository(modelContext: modelContext)
        let trimmedName = stopName.trimmingCharacters(in: .whitespaces)

        if let existingStop {
            repository.updateStop(
                existingStop,
                name: trimmedName,
                time: selectedTime,
                location: location,
                notes: notes,
                budget: budgetValue
            )
        } else {
            repository.addStop(
                to: destination,
                name: trimmedName,
                time: selectedTime,
                location: location,
                notes: notes,
                budget: budgetValue
            )
        }
    }
}