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
    
    let purposes = ["Mall", "Food", "Sport", "Museum", "Others"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Destination Info")) {
                    TextField("Name (e.g. Blok M Square)", text: $destinationName)
                    Picker("Purpose", selection: $selectedPurpose) {
                        ForEach(purposes, id: \.self) {
                            Text($0)
                        }
                    }
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
                        let newDest = Destination(name: destinationName, purpose: selectedPurpose)
                        outing.destinations.append(newDest)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(destinationName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
