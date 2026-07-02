import SwiftUI

struct CalendarEventCard: View {
    let outing: Outing
    
    private var totalStops: Int {
        outing.destinations.flatMap { $0.stops }.count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 24))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(outing.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(totalStops) Stops")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
