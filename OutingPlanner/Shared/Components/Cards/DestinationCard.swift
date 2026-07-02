//
//  DestinationCard.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI

struct DestinationCard: View {
    @Bindable var destination: Destination
    var onToggleStopChecked: (Stops) -> Void
    var onDeleteStop: (Stops) -> Void
    var onAddStop: () -> Void
    var onDeleteDestination: () -> Void

    // Tap di header untuk expand/collapse hanya hiasan navigasi lokal,
    // jadi cukup disimpan sebagai state lokal kartu ini.
    @State private var isExpanded: Bool = false
    // Mode edit: memunculkan tong sampah di setiap stop + di destinasi,
    // dan mengganti tombol pensil menjadi tombol Done.
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var stopToDelete: Stops?



    private var totalBudget: Int {
        destination.stops.reduce(0) { $0 + $1.budget }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if isExpanded {
                Divider()
                    .padding(.vertical, 12)

                VStack(spacing: 14) {
                    let sortedStops = destination.stops.sorted(by: { $0.time < $1.time })
                    ForEach(Array(sortedStops.enumerated()), id: \.element.id) { index, stop in
                        StopCard(
                            stop: stop,
                            isEditing: isEditing,
                            isLast: index == sortedStops.count - 1,
                            onToggleChecked: { onToggleStopChecked(stop) },
                            onDelete: { stopToDelete = stop }
                        )
                    }

                    HStack {
                        Button(action: {
                            onAddStop()
                        }) {
                            Label("Add Stop", systemImage: "plus.square")
                                .font(.body)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
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
            Text("Are you sure you want to delete '\(destination.name)'? Semua stop di dalam destinasi ini akan ikut terhapus.")
        }
        .confirmationDialog(
            "Delete Stop?",
            isPresented: Binding(
                get: { stopToDelete != nil },
                set: { if !$0 { stopToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let stop = stopToDelete {
                    onDeleteStop(stop)
                }
                stopToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                stopToDelete = nil
            }
        } message: {
            if let stop = stopToDelete {
                Text("Are you sure you want to delete '\(stop.name)'?")
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                guard !isEditing else { return }
                withAnimation(.snappy(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        if isEditing {
                            TextField("Destination Name", text: $destination.name)
                                .font(.headline)
                                .bold()
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(destination.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }

                        if isEditing {
                            Menu {
                                ForEach(["Mall", "Food", "Sport", "Museum", "Others"], id: \.self) { purpose in
                                    Button(purpose) {
                                        destination.purpose = purpose
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(destination.purpose.isEmpty ? "Select Purpose" : destination.purpose)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 10))
                                }
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(Color(UIColor.tertiarySystemFill))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                            }
                        } else {
                            Text(destination.purpose)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        chip("\(destination.stops.count) Stop")
                        chip(totalBudget == 0 ? "Rp 0" : Formatters.rupiahShort(totalBudget))
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            if isEditing {
                HStack(spacing: 8) {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.red)
                            .clipShape(Circle())
                    }

                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            isEditing = false
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .buttonStyle(.borderedProminent)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        isEditing = true
                        isExpanded = true
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
//                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.2), value: isEditing)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(Capsule())
    }
}

#Preview {
    let destination = Destination(name: "Blok M Square", purpose: "Mall")
    let stop1 = Stops(name: "Bakmi GM", time: Date(), location: "Lantai 2", notes: "Beli Bakmi goreng spesial", budget: 60_000)
    stop1.isChecked = true
    let stop2 = Stops(name: "Gramedia", time: Date().addingTimeInterval(7_200), location: "Lantai 3", notes: "Beli buku tereliye", budget: 90_000)
    let stop3 = Stops(name: "J.CO Donuts", time: Date().addingTimeInterval(14_400), location: "Lantai 1", notes: "", budget: 50_000)
    destination.stops = [stop1, stop2, stop3]

    return DestinationCard(
        destination: destination,
        onToggleStopChecked: { _ in },
        onDeleteStop: { _ in },
        onAddStop: {},
        onDeleteDestination: {}
    )
    .padding()
}
