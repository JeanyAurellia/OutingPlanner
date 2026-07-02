import SwiftUI
import SwiftData

struct UpcomingOutingsView: View {
    @Query var allOutings: [Outing]
    
    private var upcomingOutings: [Outing] {
        allOutings
            .filter { $0.date != nil }
            .sorted { abs($0.date!.timeIntervalSinceNow) < abs($1.date!.timeIntervalSinceNow) }
    }
    
    var body: some View {
        ScrollView {
            if upcomingOutings.isEmpty {
                Text("No upcoming outings")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(0..<upcomingOutings.count, id: \.self) { index in
                        let outing = upcomingOutings[index]
                        NavigationLink(value: outing) {
                            OutingCard(outing: outing, isFirstUpcoming: index == 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Upcoming")
        .navigationBarTitleDisplayMode(.inline)
    }
}
