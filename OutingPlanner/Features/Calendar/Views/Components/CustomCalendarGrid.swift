import SwiftUI

struct DateValue: Hashable {
    var day: Int
    var date: Date
}

struct CustomCalendarGrid: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    var outings: [Outing]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Month Year and arrows
            HStack {
                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            
            // Days of week
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                // Days
                ForEach(extractDates(), id: \.self) { value in
                    CardView(value: value)
                        .onTapGesture {
                            if value.day != -1 {
                                selectedDate = value.date
                            }
                        }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack(spacing: 4) {
            if value.day != -1 {
                let isSelected = calendar.isDate(value.date, inSameDayAs: selectedDate)
                let isToday = calendar.isDate(value.date, inSameDayAs: Date())
                let hasOuting = outings.contains { calendar.isDate($0.date ?? Date.distantPast, inSameDayAs: value.date) }
                
                Text("\(value.day)")
                    .font(.body)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                    )
                
                // Dot
                Circle()
                    .fill(hasOuting ? Color.blue : Color.clear)
                    .frame(width: 4, height: 4)
            } else {
                Text("")
                    .frame(width: 32, height: 32)
            }
        }
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func extractDates() -> [DateValue] {
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: currentMonthStart)!
        let numDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: currentMonthStart)
        
        var days: [DateValue] = []
        
        // Pad empty days
        for _ in 1..<firstWeekday {
            days.append(DateValue(day: -1, date: Date()))
        }
        
        // Add actual days
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: currentMonthStart) {
                days.append(DateValue(day: day, date: date))
            }
        }
        
        return days
    }
}
