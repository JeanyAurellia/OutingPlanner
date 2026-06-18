//
//  AddDestinationViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//


//
//  AddDestinationViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class AddDestinationViewModel: ObservableObject {
    @Published var destinationName: String
    @Published var selectedCategory: String

    /// Pilihan kategori default yang ditampilkan sebagai chip di form.
    let categoryOptions = ["Mall", "Food", "Sport", "Museum", "Others"]

    let outing: Outing
    private let existingDestination: Destination?

    var isEditMode: Bool { existingDestination != nil }
    var navigationTitle: String { isEditMode ? "Edit Destination" : "Add Destination" }
    var isSaveDisabled: Bool { destinationName.trimmingCharacters(in: .whitespaces).isEmpty }

    init(outing: Outing, existingDestination: Destination? = nil) {
        self.outing = outing
        self.existingDestination = existingDestination
        self.destinationName = existingDestination?.name ?? ""
        self.selectedCategory = existingDestination?.category ?? "Mall"
    }

    func save(modelContext: ModelContext) {
        let repository = OutingRepository(modelContext: modelContext)
        let trimmedName = destinationName.trimmingCharacters(in: .whitespaces)

        if let existingDestination {
            repository.updateDestination(existingDestination, name: trimmedName, category: selectedCategory)
        } else {
            repository.addDestination(to: outing, name: trimmedName, category: selectedCategory)
        }
    }
}