//
//  EventEditorView.swift
//  84Days
//
//  Created by Isaac Evans on 5/10/2026.
//

import SwiftUI
import SwiftData

struct EventEditorView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var event: CalendarEvent
    
    private let isNewEvent: Bool
    private let coral = Color(red: 1.0, green: 0.451, blue: 0.349)
    
    init(initialDate: Date) {
        let calendar = Calendar.current
        
        let start = calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: initialDate
        ) ?? initialDate
        
        let end = calendar.date(
            byAdding: .hour,
            value: 1,
            to: start
        ) ?? start
        
        _event = State(
            initialValue: CalendarEvent(
                title: "",
                startDate: start,
                endDate: end
            )
        )
        
        self.isNewEvent = true
    }
    
    init(event: CalendarEvent) {
        _event = State(initialValue: event)
        self.isNewEvent = false
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Basic Information
                
                Section {
                    TextField(
                        "Event title",
                        text: $event.title
                    )
                    .font(.headline)
                }
                
                // MARK: Date & Time
                
                Section("Date & Time") {
                    
                    Toggle(
                        "All-day",
                        isOn: $event.isAllDay
                    )
                    
                    DatePicker(
                        "Starts",
                        selection: $event.startDate,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )
                    
                    DatePicker(
                        "Ends",
                        selection: $event.endDate,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )
                }
                
                // MARK: Location
                
                Section("Location") {
                    TextField(
                        "Add a location",
                        text: $event.location
                    )
                }
                
                // MARK: Notes
                
                Section("Notes") {
                    TextField(
                        "Add notes",
                        text: $event.notes,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                }
                
                // MARK: Calendar
                
                Section("Calendar") {
                    HStack {
                        Label(
                            "Calendar",
                            systemImage: "calendar"
                        )
                        
                        Spacer()
                        
                        Text(event.calendarName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(
                isNewEvent
                ? "New Event"
                : "Edit Event"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        save()
                    }
                    .foregroundStyle(coral)
                    .fontWeight(.semibold)
                    .disabled(
                        event.title
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
                
                if !isNewEvent {
                    ToolbarItem(
                        placement: .bottomBar
                    ) {
                        Button(role: .destructive) {
                            deleteEvent()
                        } label: {
                            Label(
                                "Delete Event",
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Save
    
    private func save() {
        
        if event.endDate < event.startDate {
            event.endDate = Calendar.current.date(
                byAdding: .hour,
                value: 1,
                to: event.startDate
            ) ?? event.startDate
        }
        
        if isNewEvent {
            modelContext.insert(event)
        }
        
        try? modelContext.save()
        
        CalendarNotificationManager.shared
            .removeReminder(for: event)
        
        if event.reminderMinutes != nil {
            Task {
                await CalendarNotificationManager.shared
                    .scheduleReminder(for: event)
            }
        }
        
        dismiss()
    }
    
    private func deleteEvent() {
        
        CalendarNotificationManager.shared
            .removeReminder(for: event)
        
        modelContext.delete(event)
        
        try? modelContext.save()
        
        dismiss()
    }
}
