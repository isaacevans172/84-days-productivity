//
//  CalendarConnectionsView.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//


import SwiftUI
import EventKit

struct CalendarConnectionsView: View {
    
    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )
    
    @StateObject private var appleCalendar =
        AppleCalendarManager()
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    CalendarConnectionRow(
                        name: "84Days",
                        subtitle: "Your 84Days calendar",
                        icon: "calendar",
                        isConnected: true,
                        coral: coral
                    )
                }
                
                Section("External calendars") {
                    
                    Button {
                        Task {
                            await appleCalendar.requestAccess()
                        }
                    } label: {
                        CalendarConnectionRow(
                            name: "Apple Calendar",
                            subtitle: appleCalendar.isConnected
                                ? "\(appleCalendar.calendars.count) calendars connected"
                                : "Connect calendars on this device",
                            icon: "calendar",
                            isConnected: appleCalendar.isConnected,
                            coral: coral
                        )
                    }
                    .buttonStyle(.plain)
                    
                    CalendarConnectionRow(
                        name: "Google Calendar",
                        subtitle: "Connect your Google calendars",
                        icon: "g.circle",
                        isConnected: false,
                        coral: coral
                    )
                    
                    CalendarConnectionRow(
                        name: "Microsoft Outlook",
                        subtitle: "Connect your Outlook calendar",
                        icon: "m.square",
                        isConnected: false,
                        coral: coral
                    )
                }
                
                if appleCalendar.isConnected {
                    Section("Apple calendars") {
                        ForEach(
                            appleCalendar.calendars,
                            id: \.calendarIdentifier
                        ) { calendar in
                            HStack {
                                Circle()
                                    .fill(.secondary)
                                    .frame(width: 10, height: 10)
                                
                                Text(calendar.title)
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                Section {
                    Text(
                        "External calendars are displayed alongside your 84Days events. You can choose which calendars are visible."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Calendar Connections")
        }
    }
}

private struct CalendarConnectionRow: View {
    
    let name: String
    let subtitle: String
    let icon: String
    let isConnected: Bool
    let coral: Color
    
    var body: some View {
        HStack(spacing: 14) {
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(
                    isConnected
                    ? coral
                    : .primary
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(coral)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
