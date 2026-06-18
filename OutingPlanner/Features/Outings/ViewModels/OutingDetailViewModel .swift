//
//  OutingDetailTab.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//


//
//  OutingDetailViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import Foundation
import SwiftData

enum OutingDetailTab: String, CaseIterable {
    case itinerary = "Itenerary"
    case packing = "Packing"
}

/// Helper Identifiable kecil supaya navigationDestination(item:) bisa membawa
/// pasangan (destination, stop) sekaligus ke StopDetailView.
struct StopRoute: Identifiable {
    let destination: Destination
    let stop: Stops
    var id: UUID { stop.id }
}

@MainActor
final class OutingDetailViewModel: ObservableObject {
    @Published var selectedTab: OutingDetailTab = .itinerary
    @Published var showAddDestination = false
    @Published var addStopTarget: Destination?
    @Published var editDestinationTarget: Destination?
    @Published var selectedStopRoute: StopRoute?
    @Published var showEditOuting = false
    @Published var showDeleteConfirmation = false

    let outing: Outing
    private let modelContext: ModelContext

    private var repository: OutingRepository {
        OutingRepository(modelContext: modelContext)
    }

    var totalStops: Int {
        outing.destinations.flatMap { $0.stops }.count
    }

    init(outing: Outing, modelContext: ModelContext) {
        self.outing = outing
        self.modelContext = modelContext
    }

    func toggleStopChecked(_ stop: Stops) {
        repository.toggleStopChecked(stop)
    }

    func deleteStop(_ stop: Stops, from destination: Destination) {
        repository.deleteStop(stop, from: destination)
    }

    func deleteDestination(_ destination: Destination) {
        repository.deleteDestination(destination, from: outing)
    }

    func deleteOuting() {
        repository.deleteOuting(outing)
    }

    func togglePackingItem(_ item: OutingPackingItem) {
        item.isChecked.toggle()
        try? modelContext.save()
    }
}