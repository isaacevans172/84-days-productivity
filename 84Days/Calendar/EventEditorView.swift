//
//  EventEditorView.swift
//  84Days
//
//  Created by Isaac Evans on 5/10/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct EventEditorView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Queries

    @Query(sort: \TaskItem.name)
    private var tasks: [TaskItem]

    @Query(sort: \Goal.name)
    private var goals: [Goal]

    // MARK: - State

    @State private var event: CalendarEvent
    @StateObject private var locationSearch = LocationSearchService()

    @State private var locationSearchText = ""

    private let isNewEvent: Bool

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    // MARK: - New Event Initialiser

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

    // MARK: - Existing Event Initialiser

    init(event: CalendarEvent) {
        _event = State(initialValue: event)
        self.isNewEvent = false
    }

    // MARK: - Body

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
                        "Search for a location",
                        text: $locationSearchText
                    )
                    .onChange(of: locationSearchText) { _, newValue in

                        locationSearch.updateSearch(
                            query: newValue
                        )
                    }

                    // Existing selected location

                    if !event.location.isEmpty {

                        HStack {

                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(coral)

                            VStack(
                                alignment: .leading,
                                spacing: 2
                            ) {

                                Text(event.location)
                                    .font(.body)

                                if let address = event.locationAddress,
                                   !address.isEmpty {

                                    Text(address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Button {
                                clearLocation()
                            } label: {

                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // MapKit search results

                    if !locationSearch.searchResults.isEmpty {

                        ForEach(
                            Array(
                                locationSearch.searchResults
                                    .enumerated()
                            ),
                            id: \.offset
                        ) { _, result in

                            Button {

                                Task {
                                    await selectLocation(result)
                                }

                            } label: {

                                HStack(
                                    alignment: .top,
                                    spacing: 12
                                ) {

                                    Image(
                                        systemName:
                                            "mappin.circle.fill"
                                    )
                                    .foregroundStyle(coral)

                                    VStack(
                                        alignment: .leading,
                                        spacing: 3
                                    ) {

                                        Text(result.title)
                                            .foregroundStyle(.primary)

                                        if !result.subtitle.isEmpty {

                                            Text(result.subtitle)
                                                .font(.caption)
                                                .foregroundStyle(
                                                    .secondary
                                                )
                                        }
                                    }

                                    Spacer()
                                }
                            }
                        }
                    }
                }


                // MARK: Productivity Links

                Section("Productivity") {

                    // Task

                    Picker(
                        selection: Binding<UUID?>(
                            get: {
                                event.taskID
                            },
                            set: { newTaskID in

                                event.taskID = newTaskID

                                // Automatically inherit the
                                // task's goal.
                                if let newTaskID,
                                   let selectedTask = tasks.first(
                                    where: {
                                        $0.id == newTaskID
                                    }
                                   ) {

                                    if selectedTask.goalID != nil {
                                        event.goalID =
                                            selectedTask.goalID
                                    }
                                }
                            }
                        )
                    ) {

                        Text("No Task")
                            .tag(UUID?.none)

                        ForEach(tasks) { task in

                            HStack {

                                Image(
                                    systemName: task.icon
                                )

                                Text(task.name)
                            }
                            .tag(Optional(task.id))
                        }

                    } label: {

                        Label(
                            "Task",
                            systemImage: "checkmark.circle"
                        )
                    }


                    // Goal

                    Picker(
                        selection: $event.goalID
                    ) {

                        Text("No Goal")
                            .tag(UUID?.none)

                        ForEach(goals) { goal in

                            HStack {

                                Image(
                                    systemName: goal.icon
                                )

                                Text(goal.name)
                            }
                            .tag(Optional(goal.id))
                        }

                    } label: {

                        Label(
                            "Goal",
                            systemImage: "target"
                        )
                    }


                    // Relationship explanation

                    if let taskID = event.taskID,
                       let selectedTask = tasks.first(
                        where: {
                            $0.id == taskID
                        }
                       ) {

                        if let goalID = selectedTask.goalID,
                           let selectedGoal = goals.first(
                            where: {
                                $0.id == goalID
                            }
                           ) {

                            HStack(
                                alignment: .top,
                                spacing: 8
                            ) {

                                Image(
                                    systemName:
                                        "arrow.turn.down.right"
                                )
                                .foregroundStyle(coral)

                                VStack(
                                    alignment: .leading,
                                    spacing: 2
                                ) {

                                    Text(
                                        "Linked through task"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )

                                    Text(selectedGoal.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
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

            .background(
                Color(.systemGroupedBackground)
            )

            .navigationTitle(
                isNewEvent
                ? "New Event"
                : "Edit Event"
            )

            .navigationBarTitleDisplayMode(.inline)

            // MARK: Toolbar

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


    // MARK: - MapKit Location Selection

    private func selectLocation(
        _ completion: MKLocalSearchCompletion
    ) async {

        do {

            let mapItem =
                try await locationSearch.selectResult(
                    completion
                )

            await MainActor.run {

                event.location =
                    mapItem.name ?? completion.title

                event.locationAddress =
                    mapItem.placemark.title

                event.latitude =
                    mapItem.placemark.coordinate.latitude

                event.longitude =
                    mapItem.placemark.coordinate.longitude

                locationSearchText = ""

                locationSearch.clearResults()
            }

        } catch {

            print(
                "MapKit location error:",
                error.localizedDescription
            )
        }
    }


    // MARK: - Clear Location

    private func clearLocation() {

        event.location = ""
        event.locationAddress = nil
        event.latitude = nil
        event.longitude = nil

        locationSearchText = ""

        locationSearch.clearResults()
    }


    // MARK: - Save

    private func save() {

        // Make sure an event can't end before it starts.

        if event.endDate < event.startDate {

            event.endDate = Calendar.current.date(
                byAdding: .hour,
                value: 1,
                to: event.startDate
            ) ?? event.startDate
        }

        // Update timestamp.

        event.updatedAt = .now

        // Automatically inherit a goal from the selected task
        // if the task has one.

        if let taskID = event.taskID,
           let selectedTask = tasks.first(
            where: {
                $0.id == taskID
            }
           ) {

            if let taskGoalID = selectedTask.goalID {

                event.goalID = taskGoalID
            }
        }

        if isNewEvent {

            event.createdAt = .now

            modelContext.insert(event)
        }

        try? modelContext.save()

        // Remove any existing reminder before scheduling
        // the updated one.

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


    // MARK: - Delete

    private func deleteEvent() {

        CalendarNotificationManager.shared
            .removeReminder(for: event)

        modelContext.delete(event)

        try? modelContext.save()

        dismiss()
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        EventEditorView(
            initialDate: .now
        )
    }
}
