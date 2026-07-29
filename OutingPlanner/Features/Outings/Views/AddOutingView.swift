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

    init(existingOuting: Outing? = nil) {
        self.existingOuting = existingOuting
        _outingName = State(initialValue: existingOuting?.name ?? "")
        _selectedDate = State(initialValue: existingOuting?.date)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                HStack(alignment: .center) {
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

                VStack(spacing: 20) {
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

    private func saveOuting() {
        let trimmedName = outingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let repository = OutingRepository(modelContext: modelContext)

        if let existingOuting {
            repository.updateOuting(existingOuting, name: trimmedName, date: selectedDate)
        } else {
            repository.saveOuting(name: trimmedName, date: selectedDate, selectedTemplateList: nil)
        }

        dismiss()
    }
}

#Preview {
    AddOutingView()
        .modelContainer(for: Outing.self, inMemory: true)
}
