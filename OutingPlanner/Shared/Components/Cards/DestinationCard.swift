//
//  DestinationCard.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

struct DestinationCard: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var destination: Destination
    var isLast: Bool = false
    var onToggleChecked: () -> Void
    var onDeleteDestination: () -> Void

    @State private var isEditing = false
    @State private var showDeleteConfirmation = false

    private let purposes = ["Mall", "Food", "Sport", "Museum", "Others"]

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            timelineMarker
            content
            editControls
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .animation(.snappy(duration: 0.2), value: isEditing)
        .confirmationDialog(
            "Delete Destination?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDeleteDestination()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(destination.name)'?")
        }
    }

    private var timelineMarker: some View {
        VStack(spacing: 3) {
            Button(action: onToggleChecked) {
                Image(systemName: destination.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(destination.isChecked ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            if !isLast {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
                    .allowsHitTesting(false)
            }
        }
    }

    private var content: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                if isEditing {
                    TextField("Destination Name", text: $destination.name)
                        .font(.subheadline.weight(.medium))
                        .textFieldStyle(.roundedBorder)

                    TextField("Location (optional)", text: $destination.location)
                        .font(.caption)
                        .textFieldStyle(.roundedBorder)

                    TextField("Notes (optional)", text: $destination.notes)
                        .font(.caption)
                        .textFieldStyle(.roundedBorder)

                    Menu {
                        ForEach(purposes, id: \.self) { purpose in
                            Button(purpose) {
                                destination.purpose = purpose
                                saveChanges()
                            }
                        }
                    } label: {
                        Label(destination.purpose.isEmpty ? "Select Purpose" : destination.purpose, systemImage: "tag")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                } else {
                    HStack(spacing: 8) {
                        Text(destination.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .strikethrough(destination.isChecked, color: .secondary)
                            .opacity(destination.isChecked ? 0.5 : 1)

                        Text(destination.purpose)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    if !destination.location.isEmpty {
                        Text(destination.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Text(destination.notes.isEmpty ? "-" : destination.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .strikethrough(destination.isChecked, color: .secondary)
                        .opacity(destination.isChecked ? 0.5 : 1)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                if isEditing {
                    DatePicker("", selection: $destination.time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .onChange(of: destination.time) { _, _ in saveChanges() }

                    HStack(spacing: 2) {
                        Text("Rp")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("Budget", value: $destination.budget, format: .number)
                            .keyboardType(.numberPad)
                            .font(.caption2)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                    }
                } else {
                    Text(destination.time.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if destination.budget > 0 {
                        Text(Formatters.rupiahShort(destination.budget))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var editControls: some View {
        Group {
            if isEditing {
                VStack(spacing: 8) {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.red)
                            .clipShape(Circle())
                    }

                    Button {
                        saveChanges()
                        withAnimation(.snappy(duration: 0.2)) {
                            isEditing = false
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        isEditing = true
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func saveChanges() {
        try? modelContext.save()
        NotificationManager.shared.cancelDestinationReminder(for: destination)
        NotificationManager.shared.scheduleDestinationReminder(for: destination)
        if let outing = destination.outing {
            NotificationManager.shared.cancelOutingReminder(for: outing)
            NotificationManager.shared.scheduleOutingReminder(for: outing)
        }
    }
}

#Preview {
    let destination = Destination(
        name: "Blok M Square",
        purpose: "Mall",
        time: Date(),
        location: "Lantai 2",
        notes: "Beli makan siang",
        budget: 60_000
    )

    return DestinationCard(
        destination: destination,
        onToggleChecked: {},
        onDeleteDestination: {}
    )
    .padding()
}
