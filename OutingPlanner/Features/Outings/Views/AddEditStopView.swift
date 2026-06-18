//
//  AddEditStopView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

struct AddEditStopView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let destination: Destination
    private var existingStop: Stops?
    
    @State private var stopName: String
    @State private var location: String
    @State private var budgetText: String
    @State private var notes: String
    @State private var selectedTime: Date
    
    init(destination: Destination, existingStop: Stops? = nil) {
        self.destination = destination
        self.existingStop = existingStop
        _stopName = State(initialValue: existingStop?.name ?? "")
        _location = State(initialValue: existingStop?.location ?? "")
        _budgetText = State(initialValue: existingStop.map { String($0.budget) } ?? "")
        _notes = State(initialValue: existingStop?.notes ?? "")
        _selectedTime = State(initialValue: existingStop?.time ?? Date())
    }
    
    private var isEditMode: Bool { existingStop != nil }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Drag handle hiasan ala sheet di mockup
                Capsule()
                    .fill(Color(white: 0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                
                // ==========================================
                // HEADER: X — Title — Checkmark
                // ==========================================
                HStack(alignment: .center) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(white: 0.18))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(isEditMode ? "Edit Stop" : "Add Stop")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { saveStop() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(stopName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(stopName.isEmpty)
                }
                .padding(.top, 16)
                
                // ==========================================
                // FORM FIELDS
                // ==========================================
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // STOP NAME
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STOP NAME")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            TextField("e.g. Mie Ayam", text: $stopName)
                                .padding()
                                .background(Color(white: 0.11))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.2), lineWidth: 1)
                                )
                        }
                        
                        // TIME
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TIME")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Spacer()
                                ZStack {
                                    Text(selectedTime.formatted(date: .omitted, time: .shortened))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color(white: 0.16))
                                        .cornerRadius(10)
                                    
                                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .opacity(0.015)
                                }
                            }
                        }
                        
                        // LOCATION
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LOCATION")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            TextField("e.g. Lantai 2", text: $location)
                                .padding()
                                .background(Color(white: 0.11))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.2), lineWidth: 1)
                                )
                        }
                        
                        // BUDGET
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BUDGET")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Rp")
                                    .foregroundColor(.secondary)
                                TextField("0", text: $budgetText)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color(white: 0.11))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                        }
                        
                        // NOTES (OPTIONAL)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES (OPTIONAL)")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            TextField("Add a note", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(white: 0.11))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top, 24)
                }
            }
            .padding(.horizontal, 20)
        }
        .environment(\.colorScheme, .dark)
    }
    
    private func saveStop() {
        let budgetValue = Int(budgetText.filter(\.isNumber)) ?? 0
        let repository = OutingRepository(modelContext: modelContext)
        
        if let existingStop {
            repository.updateStop(
                existingStop,
                name: stopName,
                time: selectedTime,
                location: location,
                notes: notes,
                budget: budgetValue
            )
        } else {
            repository.addStop(
                to: destination,
                name: stopName,
                time: selectedTime,
                location: location,
                notes: notes,
                budget: budgetValue
            )
        }
        dismiss()
    }
}

#Preview {
    let destination = Destination(name: "Blok M Square", category: "Mall")
    return AddEditStopView(destination: destination)
        .modelContainer(for: Outing.self, inMemory: true)
}
