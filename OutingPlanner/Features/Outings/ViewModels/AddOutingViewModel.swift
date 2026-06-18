//
//  AddOutingViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//


//
//  AddOutingViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

@MainActor
final class AddOutingViewModel: ObservableObject {
    @Published var outingName: String
    @Published var selectedDate: Date?

    /// Jika nil berarti mode tambah outing baru. Jika terisi berarti mode edit.
    private let existingOuting: Outing?

    var isEditMode: Bool { existingOuting != nil }
    var navigationTitle: String { isEditMode ? "Edit Outing" : "Add Outing" }
    var isSaveDisabled: Bool { outingName.trimmingCharacters(in: .whitespaces).isEmpty }

    init(existingOuting: Outing? = nil) {
        self.existingOuting = existingOuting
        self.outingName = existingOuting?.name ?? ""
        self.selectedDate = existingOuting?.date
    }

    func save(modelContext: ModelContext) {
        let repository = OutingRepository(modelContext: modelContext)
        let trimmedName = outingName.trimmingCharacters(in: .whitespaces)

        if let existingOuting {
            repository.updateOuting(existingOuting, name: trimmedName, date: selectedDate)
        } else {
            repository.saveOuting(name: trimmedName, date: selectedDate, selectedTemplateList: nil)
        }
    }
}