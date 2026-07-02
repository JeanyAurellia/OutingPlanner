import SwiftUI
import SwiftData

struct AddBelongingListSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var listToEdit: BelongingList? = nil
    
    @State private var listName: String = ""
    @State private var selectedIcon: String = "umbrella"
    
    private let availableIcons = [
        "umbrella", "clipboard", "ticket", "dumbbell", "plus.app",
        "suitcase", "bag", "fork.knife", "signpost.right", "mountain.2"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 5)
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // Category Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("CATEGORY NAME")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Liburan", text: $listName)
                        .padding()
                        .autocorrectionDisabled(true)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Icons
                VStack(alignment: .leading, spacing: 8) {
                    Text("ICON")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(icon, systemImage: icon) {
                                selectedIcon = icon
                            }
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(selectedIcon == icon ? Color.primary : Color(UIColor.secondarySystemFill))
                            .cornerRadius(12)
                            .foregroundColor(selectedIcon == icon ? Color(UIColor.systemBackground) : .primary)
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(listToEdit == nil ? "Add Belonging List" : "Edit Belonging List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", systemImage: "checkmark") {
                        saveList()
                    }
                    .labelStyle(.iconOnly)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .disabled(listName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            if let list = listToEdit {
                listName = list.name
                selectedIcon = list.iconName.isEmpty ? "umbrella" : list.iconName
            }
        }
    }
    
    private func saveList() {
        if let list = listToEdit {
            list.name = listName
            list.iconName = selectedIcon
        } else {
            let newList = BelongingList(name: listName, iconName: selectedIcon)
            modelContext.insert(newList)
        }
        try? modelContext.save()
        dismiss()
    }
}
