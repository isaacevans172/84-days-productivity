//
//  ExternalCalendarEventCard.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//


import SwiftUI
import EventKit

struct ExternalCalendarEventCard: View {
    
    let event: EKEvent
    
    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            RoundedRectangle(cornerRadius: 3)
                .fill(coral.opacity(0.7))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 5) {
                
                Text(event.title ?? "Untitled Event")
                    .font(.headline)
                
                if event.isAllDay {
                    
                    Text("All day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                } else {
                    
                    Text(
                        "\(event.startDate.formatted(date: .omitted, time: .shortened)) – \(event.endDate.formatted(date: .omitted, time: .shortened))"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                if let location = event.location,
                   !location.isEmpty {
                    
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let calendarTitle = event.calendar?.title {
                    
                    Label(calendarTitle, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}