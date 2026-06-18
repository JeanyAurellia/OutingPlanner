//
//  DetailTab.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//


//
//  DetailOutingView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

private enum DetailTab: String, CaseIterable {
    case itinerary = "Itenerary"
    case packing = "Packing"
}

// Helper Identifiable kecil supaya navigationDestination(item:) bisa membawa
// pasangan (destination, stop) sekaligus ke StopDetailView.
private struct StopRoute: Identifiable {
    let destination: Destination
    let stop: Stops
    var id: UUID { stop.id }
}

struct DetailOutingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var outing: Outing
    
    @State private var selectedTab: DetailTab = .itinerary
    @State private var showAddDestination = false
    @State private var addStopTarget: Destination?
    @State private var selectedStopRoute: StopRoute?
    @State private var showEditOuting = false
    @State private var showDeleteConfirmation = false
    
    private var repository: OutingRepository {
        OutingRepository(modelContext: modelContext)
    }
    
    private var totalStops: Int {
        outing.destinations.flatMap { $0.stops }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                
                Text(outing.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.top, 4)
                
                if let date = outing.date {
                    Text(formattedDate(date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                statsRow
                
                tabPicker
                
                if selectedTab == .itinerary {
                    itineraryContent
                } else {
                    packingContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAddDestination) {
            AddDestinationView(outing: outing)
        }
        .sheet(item: $addStopTarget) { destination in
            AddEditStopView(destination: destination)
        }
        .sheet(isPresented: $showEditOuting) {
            AddOutingView(existingOuting: outing)
        }
        .navigationDestination(item: $selectedStopRoute) { route in
            StopDetailView(destination: route.destination, stop: route.stop)
        }
        .confirmationDialog(
            "Hapus \(outing.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Hapus Outing", role: .destructive) {
                repository.deleteOuting(outing)
                dismiss()
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Semua destinasi dan stop di outing ini akan ikut terhapus.")
        }
        .environment(\.colorScheme, .dark)
    }
    
    // ==========================================
    // HEADER: back chevron — ... menu (Edit/Delete Outing)
    // ==========================================
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(white: 0.16))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Menu {
                Button {
                    showEditOuting = true
                } label: {
                    Label("Edit Outing", systemImage: "square.and.pencil")
                }
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Outing", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(white: 0.16))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }
    
    private var statsRow: some View {
        HStack(spacing: 10) {
            statBox(label: "Destinasi", value: "\(outing.destinations.count)")
            statBox(label: "Stop", value: "\(totalStops)")
            statBox(label: "Budget", value: Formatters.rupiahBig(outing.totalBudget))
        }
    }
    
    private func statBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(white: 0.14))
        .cornerRadius(14)
    }
    
    // ==========================================
    // SEGMENTED CONTROL: Itenerary | Packing
    // ==========================================
    private var tabPicker: some View {
        HStack(spacing: 4) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .foregroundColor(.white)
                        .background(selectedTab == tab ? Color(white: 0.32) : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(Color(white: 0.12))
        .clipShape(Capsule())
    }
    
    private var itineraryContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Button {
                    showAddDestination = true
                } label: {
                    Label("Add Destination", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                }
                .tint(.blue)
            }
            
            if outing.destinations.isEmpty {
                Text("Belum ada destinasi. Tap \"Add Destination\" untuk menambahkan.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                VStack(spacing: 16) {
                    ForEach(outing.destinations) { destination in
                        DestinationCard(
                            destination: destination,
                            onToggleStopChecked: { stop in
                                repository.toggleStopChecked(stop)
                            },
                            onTapStop: { stop in
                                selectedStopRoute = StopRoute(destination: destination, stop: stop)
                            },
                            onDeleteStop: { stop in
                                repository.deleteStop(stop, from: destination)
                            },
                            onAddStop: {
                                addStopTarget = destination
                            },
                            onDeleteDestination: {
                                repository.deleteDestination(destination, from: outing)
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var packingContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if outing.packingItems.isEmpty {
                Text("Belum ada packing list untuk outing ini.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(outing.packingItems) { item in
                        Button {
                            item.isChecked.toggle()
                            try? modelContext.save()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? .blue : .secondary)
                                Text(item.name)
                                    .foregroundColor(.primary)
                                    .strikethrough(item.isChecked, color: .secondary)
                                    .opacity(item.isChecked ? 0.5 : 1)
                                Spacer()
                            }
                            .padding()
                            .background(Color(white: 0.11))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

// ==========================================
// PREVIEW GENERATOR (SWIFTDATA)
// ==========================================
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer = {
        let container = try! ModelContainer(for: Outing.self, Destination.self, Stops.self, configurations: config)
        let calendar = Calendar.current
        let dateBlokM = calendar.date(from: DateComponents(year: 2026, month: 6, day: 17))!
        let outing = Outing(name: "Jalan-jalan ke Blok M", date: dateBlokM)
        
        let dest1 = Destination(name: "Blok M Square", category: "Mall")
        let stop1 = Stops(name: "Bakmi GM", time: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!, location: "Lantai 2", notes: "Beli Bakmi goreng spesial", budget: 60_000, isChecked: true)
        let stop2 = Stops(name: "Gramedia", time: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!, location: "Lantai 3", notes: "Beli buku tereliye", budget: 90_000)
        let stop3 = Stops(name: "J.CO Donuts", time: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!, location: "Lantai 1", notes: "", budget: 50_000)
        dest1.stops = [stop1, stop2, stop3]
        
        let dest2 = Destination(name: "Blok M Plaza", category: "Kuliner")
        let stop4 = Stops(name: "Es Teler 77", time: calendar.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!, location: "Lantai 1", notes: "", budget: 100_000)
        dest2.stops = [stop4]
        
        outing.destinations = [dest1, dest2]
        container.mainContext.insert(outing)
        return container
    }()
    
    return NavigationStack {
        DetailOutingView(outing: {
            let descriptor = FetchDescriptor<Outing>()
            return try! container.mainContext.fetch(descriptor).first!
        }())
    }
    .modelContainer(container)
}