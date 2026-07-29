//
//  DetailOutingView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

private enum DetailTab: String, CaseIterable {
    case itinerary = "Itinerary"
    case belonging = "Belonging"
}

struct DetailOutingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var outing: Outing

    @State private var selectedTab: DetailTab = .itinerary
    @State private var showAddDestination = false
    @State private var showEditOuting = false
    @State private var showDeleteConfirmation = false
    @State private var showAttachSheet = false

    private var repository: OutingRepository {
        OutingRepository(modelContext: modelContext)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(outing.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.top, 4)

                if let date = outing.eventStartDate ?? outing.date {
                    Text(formattedDate(date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                statsRow
                tabPicker

                if selectedTab == .itinerary {
                    itineraryContent
                } else {
                    belongingContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showAddDestination) {
            AddDestinationView(outing: outing)
        }
        .sheet(isPresented: $showEditOuting) {
            AddOutingView(existingOuting: outing)
        }
        .sheet(isPresented: $showAttachSheet) {
            AttachListSheet(outing: outing)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showEditOuting = true
                    } label: {
                        Label("Edit Outing", systemImage: "square.and.pencil")
                    }
                    .tint(.primary)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Outing", systemImage: "trash")
                            .tint(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .confirmationDialog(
            "Delete Outing?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                repository.deleteOuting(outing)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(outing.name)'? Semua destinasi di outing ini akan ikut terhapus.")
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statBox(label: "Destinasi", value: "\(outing.destinations.count)")
            statBox(label: "Selesai", value: "\(outing.destinations.filter { $0.isChecked }.count)")
            statBox(label: "Budget", value: outing.totalBudget == 0 ? "Rp 0" : Formatters.rupiahBig(outing.totalBudget))
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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }

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
                        .foregroundColor(.primary)
                        .background(selectedTab == tab ? Color(UIColor.systemFill) : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(Color(UIColor.tertiarySystemFill))
        .clipShape(Capsule())
    }

    private var itineraryContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                PrimaryAddButton(title: "Add Destination") {
                    showAddDestination = true
                }
            }

            if outing.destinations.isEmpty {
                Text("Belum ada destinasi. Tap \"Add Destination\" untuk menambahkan.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                let sortedDestinations = outing.destinations.sorted { $0.time < $1.time }
                VStack(spacing: 14) {
                    ForEach(Array(sortedDestinations.enumerated()), id: \.element.id) { index, destination in
                        DestinationCard(
                            destination: destination,
                            isLast: index == sortedDestinations.count - 1,
                            onToggleChecked: {
                                repository.toggleDestinationChecked(destination)
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

    private var belongingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                PrimaryAddButton(title: "Attach List") {
                    showAttachSheet = true
                }
            }

            if outing.belongingItems.isEmpty {
                Text("Belum ada belonging list untuk outing ini.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                let groupedItems = Dictionary(grouping: outing.belongingItems, by: { $0.categoryName })
                let sortedCategories = groupedItems.keys.sorted { cat1, cat2 in
                    if cat1 == "Everyday Carry" { return true }
                    if cat2 == "Everyday Carry" { return false }
                    return cat1 < cat2
                }

                VStack(spacing: 16) {
                    ForEach(sortedCategories, id: \.self) { category in
                        let items = groupedItems[category] ?? []
                        let checkedCount = items.filter { $0.isChecked }.count

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(checkedCount)/\(items.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            ForEach(items.sorted { $0.name < $1.name }) { item in
                                Button {
                                    item.isChecked.toggle()
                                    try? modelContext.save()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundColor(item.isChecked ? .blue : .secondary)
                                        Text(item.name)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .strikethrough(item.isChecked, color: .secondary)
                                            .opacity(item.isChecked ? 0.5 : 1)
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
            }
        }
        .onAppear {
            seedEverydayCarryForOutingIfNeeded()
        }
    }

    private func seedEverydayCarryForOutingIfNeeded() {
        let hasEverydayCarry = outing.belongingItems.contains { $0.categoryName == "Everyday Carry" }
        guard !hasEverydayCarry else { return }

        let descriptor = FetchDescriptor<BelongingList>(predicate: #Predicate { $0.name == "Everyday Carry" })
        if let edc = try? modelContext.fetch(descriptor).first {
            for item in edc.items {
                let newItem = OutingBelongingItem(name: item.name, isChecked: false, categoryName: "Everyday Carry")
                outing.belongingItems.append(newItem)
            }
            try? modelContext.save()
        } else {
            let edc = BelongingList(name: "Everyday Carry", iconName: "briefcase")
            modelContext.insert(edc)
            let items = ["Dompet", "Kunci Kendaraan", "Handphone", "Charger/Powerbank", "Air Minum", "Tisu"]
            for itemName in items {
                let templateItem = BelongingItem(name: itemName)
                edc.items.append(templateItem)

                let newItem = OutingBelongingItem(name: itemName, isChecked: false, categoryName: "Everyday Carry")
                outing.belongingItems.append(newItem)
            }
            try? modelContext.save()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        return date.formatted(date: .long, time: .shortened)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer = {
        let container = try! ModelContainer(for: Outing.self, Destination.self, configurations: config)
        let calendar = Calendar.current
        let dateBlokM = calendar.date(from: DateComponents(year: 2026, month: 6, day: 17))!
        let outing = Outing(name: "Jalan-jalan ke Blok M", date: dateBlokM)

        let dest1 = Destination(
            name: "Blok M Square",
            purpose: "Mall",
            time: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!,
            location: "Lantai 2",
            notes: "Beli Bakmi goreng spesial",
            budget: 60_000,
            isChecked: true
        )
        let dest2 = Destination(
            name: "Gramedia",
            purpose: "Mall",
            time: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
            location: "Lantai 3",
            notes: "Beli buku tereliye",
            budget: 90_000
        )
        let dest3 = Destination(
            name: "J.CO Donuts",
            purpose: "Food",
            time: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!,
            location: "Lantai 1",
            notes: "",
            budget: 50_000
        )

        outing.destinations = [dest1, dest2, dest3]
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
