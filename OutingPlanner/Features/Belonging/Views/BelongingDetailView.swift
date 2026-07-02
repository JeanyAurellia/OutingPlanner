import SwiftUI
import SwiftData

struct BelongingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var belongingList: BelongingList
    
    @State private var newItemName: String = ""
    @State private var itemToEdit: BelongingItem?
    @State private var editItemName: String = ""
    @State private var itemToDelete: BelongingItem?
    @State private var showDeleteListConfirmation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header: Add Item
            HStack(spacing: 12) {
                TextField("Add an Item", text: $newItemName)
                    .padding()
                    .autocorrectionDisabled(true)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                
                PrimaryAddButton {
                    addItem()
                }
                .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // List of items
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(belongingList.items) { item in
                        HStack {
                            Text(item.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Menu {
                                Button("Edit", systemImage: "square.and.pencil") {
                                    editItemName = item.name
                                    itemToEdit = item
                                }
                                .tint(.primary)
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    itemToDelete = item
                                }
                                .tint(.red)
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.secondary)
                                    .rotationEffect(.degrees(90))
                                    .frame(width: 32, height: 32)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .onDelete(perform: deleteItem)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(belongingList.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit", systemImage: "square.and.pencil") {
                        // Action for edit
                    }
                    .tint(.primary)
                    Button(role: .destructive) {
                        showDeleteListConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(.red)
                    }
                    .tint(.red)
                } label: {
                    Image(systemName: "ellipsis")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .tint(.primary)
            }
        }
        .alert("Edit Item", isPresented: Binding(get: { itemToEdit != nil }, set: { if !$0 { itemToEdit = nil } })) {
            TextField("Item Name", text: $editItemName)
            Button("Cancel", role: .cancel) { itemToEdit = nil }
            Button("Save") {
                if let item = itemToEdit {
                    item.name = editItemName
                    try? modelContext.save()
                }
                itemToEdit = nil
            }
        }
        .confirmationDialog(
            "Delete Belonging List?",
            isPresented: $showDeleteListConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(belongingList)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(belongingList.name)'?")
        }
        .confirmationDialog(
            "Delete '\(itemToDelete?.name ?? "")'?",
            isPresented: Binding(get: { itemToDelete != nil }, set: { if !$0 { itemToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    modelContext.delete(item)
                    try? modelContext.save()
                }
                itemToDelete = nil
            }
            Button("Cancel", role: .cancel) { itemToDelete = nil }
        } message: {
            if let item = itemToDelete {
                Text("Are you sure you want to delete '\(item.name)'?")
            }
        }
    }
    
    private func addItem() {
        let trimmed = newItemName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let newItem = BelongingItem(name: trimmed)
        belongingList.items.append(newItem)
        try? modelContext.save()
        
        newItemName = ""
    }
    
    private func deleteItem(offsets: IndexSet) {
        for index in offsets {
            let item = belongingList.items[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}


