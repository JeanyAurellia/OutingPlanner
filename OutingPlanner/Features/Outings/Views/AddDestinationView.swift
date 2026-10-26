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
    @State private var selectedPlace: PlaceResult?
    @State private var showPlacePicker = false
    @State private var selectedTime = Date()
    @State private var budgetText = ""
    @State private var notes = ""

    private func purpose(from categories: [String]) -> String {
        if categories.contains(where: { $0.contains("catering") }) {
            return "Food"
        }

        if categories.contains(where: { $0.contains("commercial") }) {
            return "Shopping"
        }

        if categories.contains(where: { $0.contains("sport") }) {
            return "Sport"
        }

        if categories.contains(where: { $0.contains("museum") }) {
            return "Museum"
        }

        if categories.contains(where: {
            $0.contains("tourism") || $0.contains("entertainment")
        }) {
            return "Entertainment"
        }

        return "Others"
    }

    private func saveDestination() {
        guard let place = selectedPlace else { return }

        let budgetValue = Int(budgetText.filter(\.isNumber)) ?? 0

        let repository = OutingRepository(modelContext: modelContext)
        repository.addDestination(
            to: outing,
            name: place.name,
            purpose: purpose(from: place.categories),
            time: selectedTime,
            location: place.address,
            notes: notes,
            budget: budgetValue
        )

        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Destination") {
                    if let place = selectedPlace {
                        Button {
                            showPlacePicker = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(place.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(place.address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        LabeledContent(
                            "Purpose",
                            value: purpose(from: place.categories)
                        )
                    } else {
                        Button {
                            showPlacePicker = true
                        } label: {
                            Label("Pilih Destinasi", systemImage: "magnifyingglass")
                        }
                    }
                }

                Section("Timeline") {
                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )

                    HStack {
                        Text("Rp")
                            .foregroundStyle(.secondary)

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
                    .disabled(selectedPlace == nil)
                }
            }
            .sheet(isPresented: $showPlacePicker) {
                PlacePickerView { place in
                    selectedPlace = place
                    showPlacePicker = false
                }
            }
        }
    }
}
