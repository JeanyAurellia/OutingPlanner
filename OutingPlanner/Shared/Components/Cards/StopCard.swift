//
//  StopCard.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI

struct StopCard: View {
    @Bindable var stop: Stops
    var isEditing: Bool = false
    var isLast: Bool = false
    var onToggleChecked: () -> Void
    var onDelete: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Leading marker: checkbox di atas, titik-titik dekoratif di bawahnya.
            // Titik-titik ini HANYA hiasan timeline, bukan tombol menu edit/delete.
            VStack(spacing: 3) {
                Button(action: onToggleChecked) {
                    Image(systemName: stop.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(stop.isChecked ? .blue : .secondary)
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

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    if isEditing {
                        TextField("Stop Name", text: $stop.name)
                            .font(.subheadline.weight(.medium))
                            .textFieldStyle(.roundedBorder)
                        TextField("Notes (optional)", text: $stop.notes)
                            .font(.caption)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(stop.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .strikethrough(stop.isChecked, color: .secondary)
                            .opacity(stop.isChecked ? 0.5 : 1)
                        
                        Text(stop.notes.isEmpty ? "-" : stop.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .strikethrough(stop.isChecked, color: .secondary)
                            .opacity(stop.isChecked ? 0.5 : 1)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    if isEditing {
                        DatePicker("", selection: $stop.time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    } else {
                        Text(stop.time.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if isEditing {
                        HStack(spacing: 2) {
                            Text("Rp")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("Budget", value: $stop.budget, format: .number)
                                .keyboardType(.numberPad)
                                .font(.caption2)
                                .frame(width: 60)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.roundedBorder)
                        }
                    } else if stop.budget > 0 {
                        Text(Formatters.rupiahShort(stop.budget))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
            }

            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.2), value: isEditing)
    }
}

#Preview {
    let stop = Stops(name: "Bakmi GM", time: Date(), location: "Lantai 2", notes: "Beli Bakmi goreng spesial", budget: 60_000)
    stop.isChecked = true

    return VStack(spacing: 14) {
        StopCard(stop: stop, onToggleChecked: {})
        StopCard(
            stop: Stops(name: "Gramedia", time: Date(), location: "Lantai 3", notes: "Beli buku tereliye", budget: 90_000),
            isEditing: true,
            onToggleChecked: {}
        )
    }
    .padding()
}
