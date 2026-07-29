//
//  AddDestinationView.swift
//  OutingPlanner
//

import SwiftUI
import SwiftData

struct AddDestinationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var outing: Outing
    @State private var destinationName = ""
    @State private var selectedPurpose = "Mall"
    @State private var selectedTime = Date()
    @State private var location = ""
    @State private var budgetText = ""
    @State private var notes = ""

    private let purposes = ["Mall", "Food", "Sport", "Museum", "Others"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Destination Info")) {
                    TextField("Name (e.g. Blok M Square)", text: $destinationName)
                    Picker("Purpose", selection: $selectedPurpose) {
                        ForEach(purposes, id: \.self) { purpose in
                            Text(purpose)
                        }
                    }
                    TextField("Location (optional)", text: $location)
                }

                Section(header: Text("Timeline")) {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    HStack {
                        Text("Rp")
                            .foregroundColor(.secondary)
                        TextField("Budget", text: $budgetText)
                            .keyboardType(.numberPad)
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDestination()
                    }
                    .disabled(destinationName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveDestination() {
        let budgetValue = Int(budgetText.filter(\.isNumber)) ?? 0
        let repository = OutingRepository(modelContext: modelContext)
        repository.addDestination(
            to: outing,
            name: destinationName.trimmingCharacters(in: .whitespacesAndNewlines),
            purpose: selectedPurpose,
            time: selectedTime,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            budget: budgetValue
        )
        dismiss()
    }
}
