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

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(outing.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)

                if let outingDate = outing.eventStartDate ?? outing.date {
                    Text(formatDate(outingDate))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(outing.destinations.count) Destinations")
                .font(.footnote)
                .foregroundColor(isFirstUpcoming ? Color(UIColor.systemCyan) : Color(UIColor.systemBlue))
        }
        .padding()
        .background(
            isFirstUpcoming
                ? Color(UIColor.systemBlue).opacity(0.15)
                : Color(UIColor.secondarySystemGroupedBackground)
        )
        .cornerRadius(16)
    }

    private func formatDate(_ date: Date) -> String {
        return date.formatted(date: .long, time: .shortened)
    }
}
