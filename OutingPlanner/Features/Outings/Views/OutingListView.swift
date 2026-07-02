//
//  OutingListView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI
import SwiftData

enum OutingListFilter: Hashable {
    case upcoming
    case draft
}

struct OutingListView: View {
    @Query var allOutings: [Outing]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddOuting = false
    
    private var upcomingOutings: [Outing] {
        let sorted = allOutings
            .filter { $0.date != nil }
            .sorted { abs($0.date!.timeIntervalSinceNow) < abs($1.date!.timeIntervalSinceNow) }
        return Array(sorted.prefix(3))
    }
    
    private var draftOutings: [Outing] {
        let drafts = allOutings.filter { $0.date == nil }
        return Array(drafts.prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // SECTION: UPCOMING
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("UPCOMING")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            NavigationLink(value: OutingListFilter.upcoming) {
                                Text("See All")
                                    .font(.subheadline)
                            }
                        }
                        
                        if upcomingOutings.isEmpty {
                            Text("No upcoming outings")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
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
                        }
                    }
                    
                    // SECTION: DRAFT
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("DRAFT")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            NavigationLink(value: OutingListFilter.draft) {
                                Text("See All")
                                    .font(.subheadline)
                            }
                        }
                        
                        if draftOutings.isEmpty {
                            Text("No drafts available")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(draftOutings) { outing in
                                    NavigationLink(value: outing) {
                                        OutingCard(outing: outing, isFirstUpcoming: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Outing")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    PrimaryAddButton { showAddOuting = true }
                    
                }
            }
            .sheet(isPresented: $showAddOuting) {
                AddOutingView()
            }
            .navigationDestination(for: Outing.self) { outing in
                DetailOutingView(outing: outing)
            }
            .navigationDestination(for: OutingListFilter.self) { filter in
                switch filter {
                case .upcoming:
                    UpcomingOutingsView()
                case .draft:
                    DraftOutingsView()
                }
            }
        }
    }
}

// ==========================================
// PREVIEW GENERATOR (SWIFTDATA) - FIXED CLOSURE
// ==========================================
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer = {
        let container = try! ModelContainer(for: Outing.self, Destination.self, Stops.self, configurations: config)
        let calendar = Calendar.current
        
        let dateBlokM = calendar.date(from: DateComponents(year: 2026, month: 6, day: 17))!
        let outing1 = Outing(name: "Jalan-jalan ke Blok M", date: dateBlokM)
        let dest1 = Destination(name: "Blok M Plaza", purpose: "Mall")
        dest1.stops = [Stops(name: "Foodcourt", time: Date(), location: "Lantai 5", notes: "Beli bakmi", budget: 50000),
                       Stops(name: "Kopi Kenangan", time: Date(), location: "Lantai UG", notes: "Kopi susu", budget: 25000)]
        outing1.destinations.append(dest1)
        
        let dateGI = calendar.date(from: DateComponents(year: 2026, month: 6, day: 20))!
        let outing2 = Outing(name: "Muterin GI", date: dateGI)
        
        let outing3 = Outing(name: "Jalan-jalan ke PIK", date: nil)
        let outing4 = Outing(name: "Nonton Film", date: nil)
        
        container.mainContext.insert(outing1)
        container.mainContext.insert(outing2)
        container.mainContext.insert(outing3)
        container.mainContext.insert(outing4)
        return container
    }()
    
    OutingListView()
        .modelContainer(container)
}
