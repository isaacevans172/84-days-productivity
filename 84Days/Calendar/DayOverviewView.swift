//
//  DayOverviewView.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//


import SwiftUI
import SwiftData

struct DayOverviewView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \CalendarEvent.startDate)
    private var events: [CalendarEvent]
    
    let selectedDate: Date
    
    private let calendar = Calendar.current
    private let coral = Color(red: 1.0, green: 0.451, blue: 0.349)
    
    private var dayEvents: [CalendarEvent] {
        events
            .filter {
                eventOccursOnDate($0, date: selectedDate)
            }
            .sorted {
                $0.startDate < $1.startDate
            }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    header
                    
                    summary
                    
                    timeline
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Day Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(
                selectedDate.formatted(
                    .dateTime
                        .weekday(.wide)
                )
            )
            .font(.largeTitle.weight(.semibold))
            
            Text(
                selectedDate.formatted(
                    .dateTime
                        .month(.wide)
                        .day()
                        .year()
                )
            )
            .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
    }
    
    // MARK: Summary
    
    private var summary: some View {
        HStack(spacing: 12) {
            SummaryCard(
                value: "\(dayEvents.count)",
                label: dayEvents.count == 1
                ? "event"
                : "events"
            )
            
            SummaryCard(
                value: formattedBusyTime,
                label: "scheduled"
            )
        }
    }
    
    private var formattedBusyTime: String {
        let totalSeconds = dayEvents.reduce(0.0) {
            total, event in
            
            let start = max(
                event.startDate,
                calendar.startOfDay(for: selectedDate)
            )
            
            let dayEnd = calendar.date(
                byAdding: .day,
                value: 1,
                to: calendar.startOfDay(
                    for: selectedDate
                )
            ) ?? selectedDate
            
            let end = min(
                event.endDate,
                dayEnd
            )
            
            return total + max(
                0,
                end.timeIntervalSince(start)
            )
        }
        
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(
            (totalSeconds.truncatingRemainder(
                dividingBy: 3600
            )) / 60
        )
        
        if hours > 0 {
            return minutes > 0
            ? "\(hours)h \(minutes)m"
            : "\(hours)h"
        }
        
        return "\(minutes)m"
    }
    
    // MARK: Timeline
    
    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCHEDULE")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(1)
            
            if dayEvents.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 30))
                        .foregroundStyle(coral)
                    
                    Text("Nothing scheduled")
                        .font(.headline)
                    
                    Text("You've got a clear day.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
            } else {
                ForEach(dayEvents) { event in
                    DayOverviewEvent(event: event)
                }
            }
        }
    }
    
    private func eventOccursOnDate(
        _ event: CalendarEvent,
        date: Date
    ) -> Bool {
        
        if event.repeatRule != "Never" {
            return event.occurs(
                on: date,
                calendar: calendar
            )
        }
        
        let dayStart = calendar.startOfDay(for: date)
        
        guard let dayEnd = calendar.date(
            byAdding: .day,
            value: 1,
            to: dayStart
        ) else {
            return false
        }
        
        return event.startDate < dayEnd &&
        event.endDate > dayStart
    }
    // MARK: - Summary Card
    
    private struct SummaryCard: View {
        
        let value: String
        let label: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(value)
                    .font(.title2.weight(.semibold))
                
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.background)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
        }
    }
    
    
    // MARK: - Event
    
    private struct DayOverviewEvent: View {
        
        let event: CalendarEvent
        
        var body: some View {
            HStack(alignment: .top, spacing: 14) {
                
                VStack(alignment: .trailing, spacing: 3) {
                    if event.isAllDay {
                        Text("ALL DAY")
                            .font(.caption.weight(.semibold))
                    } else {
                        Text(
                            event.startDate.formatted(
                                date: .omitted,
                                time: .shortened
                            )
                        )
                        .font(.subheadline.weight(.medium))
                    }
                }
                .frame(width: 72, alignment: .trailing)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(.secondary)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text(event.title)
                        .font(.headline)
                    
                    if !event.location.isEmpty {
                        Label(
                            event.location,
                            systemImage: "location"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(.background)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
        }
    }
    
}
