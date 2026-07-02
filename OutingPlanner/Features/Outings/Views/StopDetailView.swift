//
//  StopDetailView.swift
//  OutingPlanner
//

import SwiftUI

struct StopDetailView: View {
    let destination: Destination
    @Bindable var stop: Stops
    
    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Destination", value: destination.name)
                LabeledContent("Stop Name", value: stop.name)
                LabeledContent("Location", value: stop.location.isEmpty ? "-" : stop.location)
                LabeledContent("Time", value: stop.time.formatted(date: .omitted, time: .shortened))
                LabeledContent("Budget", value: Formatters.rupiahBig(stop.budget))
            }
            
            Section("Notes") {
                TextField("Add notes...", text: $stop.notes, axis: .vertical)
                    .lineLimit(3...10)
            }
        }
        .navigationTitle(stop.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
