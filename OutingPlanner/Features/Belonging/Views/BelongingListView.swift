import SwiftUI
import SwiftData

struct BelongingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BelongingList.name) private var lists: [BelongingList]
    
    @State private var showAddSheet = false
    @State private var listToEdit: BelongingList? = nil
    
    private func seedEverydayCarryIfNeeded() {
        guard !lists.contains(where: { $0.name == "Everyday Carry" }) else { return }
        
        let edc = BelongingList(name: "Everyday Carry", iconName: "briefcase")
        modelContext.insert(edc)
        
        let items = ["Dompet", "Kunci Kendaraan", "Handphone", "Charger/Powerbank", "Air Minum", "Tisu"]
        for itemName in items {
            let item = BelongingItem(name: itemName)
            edc.items.append(item)
        }
        
        try? modelContext.save()
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Manage reusable belonging lists")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(lists) { list in
                        NavigationLink(destination: BelongingDetailView(belongingList: list)) {
                            BelongingListCard(list: list) {
                                listToEdit = list
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Belonging List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PrimaryAddButton { showAddSheet = true }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddBelongingListSheet()
        }
        .sheet(item: $listToEdit) { list in
            AddBelongingListSheet(listToEdit: list)
        }
        .onAppear {
            seedEverydayCarryIfNeeded()
        }
    }
}

struct BelongingListCard: View {
    @Environment(\.modelContext) private var modelContext
    let list: BelongingList
    var onEdit: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Image(systemName: list.iconName.isEmpty ? "bag" : list.iconName)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(width: 48, height: 48)
                    .background(Color.primary)
                    .clipShape(.rect(cornerRadius: 12))
                
                Spacer()
                
                Menu {
                    Button("Edit", systemImage: "square.and.pencil") {
                        onEdit()
                    }
                    .tint(.primary)
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 28, height: 28)
                        .background(Color.secondary.opacity(0.2), in: Circle())
                }
                
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(list.items.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .confirmationDialog(
            "Delete Belonging List?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(list)
                try? modelContext.save()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(list.name)'?")
        }
    }
}

#Preview {
    let list = BelongingList(id: UUID(), name: "Test List", iconName: "")
    BelongingListCard(list: list, onEdit: {})
}
