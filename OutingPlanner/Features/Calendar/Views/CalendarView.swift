import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \Outing.date, order: .forward) private var outings: [Outing]
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CustomCalendarGrid(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    outings: outings
                )
                .padding(.horizontal)
                
                // Header untuk daftar event pada hari tersebut
                let selectedOutings = outingsForDate(selectedDate)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(selectedDate.formatted(date: .complete, time: .omitted).uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    
                    if !selectedOutings.isEmpty {
                        ForEach(selectedOutings) { outing in
                            NavigationLink(value: outing) {
                                CalendarEventCard(outing: outing)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    } else {
                        // Empty state (no plan)
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.minus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No plans for this date.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Calendar")
        .navigationDestination(for: Outing.self) { outing in
            DetailOutingView(outing: outing)
        }
    }
    
    private func outingsForDate(_ date: Date) -> [Outing] {
        outings.filter { Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: date) }
    }
}
