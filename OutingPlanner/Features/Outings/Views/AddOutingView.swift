//
//  AddOutingView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

struct AddOutingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var existingOuting: Outing?
    
    @State private var outingName: String
    @State private var selectedDate: Date?
    
    // State internal untuk menangani interaksi DatePicker native
    @State private var internalDate: Date
    
    init(existingOuting: Outing? = nil) {
        self.existingOuting = existingOuting
        _outingName = State(initialValue: existingOuting?.name ?? "")
        _selectedDate = State(initialValue: existingOuting?.date)
        _internalDate = State(initialValue: existingOuting?.date ?? Date())
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                
                // ==========================================
                // CUSTOM HEADER TOMBOL NATIVE MOCKUP FIGMA
                // ==========================================
                HStack(alignment: .center) {
                    // Tombol Silang (X) Gelap
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(existingOuting != nil ? "Edit Outing" : "Add Outing")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Tombol Centang (✓) Biru
                    Button(action: { saveOuting() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(outingName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(outingName.isEmpty)
                }
                .padding(.top, 8)
                
                // ==========================================
                // INPUT FIELD BLOCK
                // ==========================================
                VStack(spacing: 20) {
                    
                    // 1. OUTING NAME
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OUTING NAME")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        TextField("Enter outing name", text: $outingName)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(UIColor.separator), lineWidth: 1)
                            )
                    }
                    
                    // 2. DATE (NATIVE COMPACT OVERLAY BEHAVIOR)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(selectedDate != nil ? "Selected Date" : "Date")
                                .font(.subheadline)
                                .foregroundColor(selectedDate != nil ? .primary : .secondary)
                            
                            Spacer()
                            
                            DatePicker("", selection: Binding(
                                get: { selectedDate ?? Date() },
                                set: { newValue in
                                    selectedDate = newValue
                                    internalDate = newValue
                                }
                            ), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        return date.formatted(date: .long, time: .omitted)
    }
    
    private func saveOuting() {
        if let existingOuting {
            existingOuting.name = outingName
            existingOuting.date = selectedDate
        } else {
            let newOuting = Outing(name: outingName, date: selectedDate)
            modelContext.insert(newOuting)
        }
        dismiss()
    }
}

#Preview {
    AddOutingView()
        .modelContainer(for: Outing.self, inMemory: true)
}
