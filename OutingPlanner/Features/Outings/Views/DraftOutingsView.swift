import SwiftUI
import SwiftData

struct DraftOutingsView: View {
    @Query(filter: #Predicate<Outing> { $0.date == nil }, sort: \Outing.createdAt, order: .forward)
    var draftOutings: [Outing]
    
    var body: some View {
        ScrollView {
            if draftOutings.isEmpty {
                Text("No drafts available")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(draftOutings) { outing in
                        NavigationLink(value: outing) {
                            OutingCard(outing: outing, isFirstUpcoming: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Draft")
        .navigationBarTitleDisplayMode(.inline)
    }
}
