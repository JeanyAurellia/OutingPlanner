import SwiftUI
import SwiftData

struct AttachListSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let outing: Outing
    @Query(sort: \BelongingList.name) private var availableLists: [BelongingList]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if unattachedLists.isEmpty {
                    Text("Semua list sudah di-attach.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(unattachedLists) { list in
                                Button {
                                    attachList(list)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(list.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text("\(list.items.count) items")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "plus")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationTitle("Attach a Belonging List")
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
                    Button("Done", systemImage: "checkmark.circle.fill") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .symbolRenderingMode(.palette)
//                    .foregroundStyle(.white, .blue)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // Derived property to only show lists that haven't been attached yet
    private var unattachedLists: [BelongingList] {
        let attachedCategoryNames = Set(outing.belongingItems.map { $0.categoryName })
        return availableLists.filter { !attachedCategoryNames.contains($0.name) }
    }
    
    private func attachList(_ list: BelongingList) {
        // Copy items into outing
        for item in list.items {
            let newItem = OutingBelongingItem(name: item.name, isChecked: false, categoryName: list.name)
            outing.belongingItems.append(newItem)
        }
        try? modelContext.save()
    }
}
