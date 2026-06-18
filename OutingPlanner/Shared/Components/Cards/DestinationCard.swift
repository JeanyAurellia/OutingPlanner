//
//  DestinationCard.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI

struct DestinationCard: View {
    let destination: Destination
    let isExpanded: Bool
    var onToggleExpand: () -> Void
    var onToggleStopChecked: (Stops) -> Void
    var onEditStop: (Stops) -> Void
    var onDeleteStop: (Stops) -> Void
    var onAddStop: () -> Void

    // Destination belum punya field time sendiri, jadi dipakai jam stop paling awal
    private var earliestTime: Date? {
        destination.stops.map(\.time).min()
    }

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
                    ForEach(destination.stops) { stop in
                        StopCard(
                            stop: stop,
                            onToggleChecked: { onToggleStopChecked(stop) },
                            onEdit: { onEditStop(stop) },
                            onDelete: { onDeleteStop(stop) }
                        )
                    }

                    Button(action: onAddStop) {
                        Label("Add Stop", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.medium))
                    }
                    .tint(.blue)
                    .padding(.top, 2)
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.11))
        .cornerRadius(16)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(destination.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(destination.category)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                HStack(spacing: 6) {
                    chip("\(destination.stops.count) Stop")
                    if let earliestTime {
                        chip(earliestTime.formatted(date: .omitted, time: .shortened))
                    }
                    chip(Formatters.rupiahShort(totalBudget))
                }
            }

            Spacer()

            Button(action: onToggleExpand) {
                Image(systemName: "square.and.pencil")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(white: 0.2))
                    .clipShape(Circle())
            }
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(white: 0.18))
            .clipShape(Capsule())
    }
}

#Preview {
    let destination = Destination(name: "Blok M Square", category: "Mall")
    let stop1 = Stops(name: "Bakmi GM", time: Date(), location: "Lantai 2", notes: "Beli Bakmi goreng spesial", budget: 60_000)
    stop1.isChecked = true
    let stop2 = Stops(name: "Gramedia", time: Date().addingTimeInterval(7_200), location: "Lantai 3", notes: "Beli buku tereliye", budget: 90_000)
    let stop3 = Stops(name: "J.CO Donuts", time: Date().addingTimeInterval(14_400), location: "Lantai 1", notes: "", budget: 50_000)
    destination.stops = [stop1, stop2, stop3]

    return DestinationCard(
        destination: destination,
        isExpanded: true,
        onToggleExpand: {},
        onToggleStopChecked: { _ in },
        onEditStop: { _ in },
        onDeleteStop: { _ in },
        onAddStop: {}
    )
    .padding()
    .background(Color.black)
    .environment(\.colorScheme, .dark)
}