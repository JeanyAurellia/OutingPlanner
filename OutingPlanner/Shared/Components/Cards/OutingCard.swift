//
//  OutingCard.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 18/06/26.
//

import SwiftUI

struct OutingCard: View {
    let outing: Outing
    let isFirstUpcoming: Bool
    
    private var totalStops: Int {
        outing.destinations.flatMap { $0.stops }.count
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(outing.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
                
                // Buka bungkus date opsional di sini
                if let outingDate = outing.date {
                    Text(formatDate(outingDate))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(totalStops) Stops")
                .font(.footnote)
                .foregroundColor(isFirstUpcoming ? Color(UIColor.systemCyan) : Color(UIColor.systemBlue))
        }
        .padding()
        .background(
            isFirstUpcoming
                ? Color(UIColor.systemBlue).opacity(0.15)
                : Color(UIColor.secondarySystemGroupedBackground) // bukan secondarySystemBackground
        )
        .cornerRadius(16)
    }
    
    private func formatDate(_ date: Date) -> String {
        return date.formatted(date: .long, time: .omitted)
    }
}

