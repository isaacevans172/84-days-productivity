//
//  DayOverviewView.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//

import SwiftUI
import SwiftData

struct DayOverviewView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Query(sort: \CalendarEvent.startDate)
    private var events: [CalendarEvent]

    @Query
    private var tasks: [TaskItem]

    @Query
    private var goals: [Goal]

    let selectedDate: Date

    private let calendar =
        Calendar.current

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    // MARK: - Day Events

    private var dayEvents: [CalendarEvent] {

        events
            .filter {
                eventOccursOnDate(
                    $0,
                    date: selectedDate
                )
            }
            .sorted {
                $0.startDate < $1.startDate
            }
    }


    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    header

                    summary

                    timeline

                    Spacer(
                        minLength: 30
                    )
                }
                .padding(
                    .horizontal,
                    20
                )
                .padding(
                    .bottom,
                    30
                )
            }

            .background(
                Color(.systemGroupedBackground)
            )

            .navigationTitle(
                "Day Overview"
            )

            .navigationBarTitleDisplayMode(
                .inline
            )

            .toolbar {

                ToolbarItem(
                    placement:
                        .cancellationAction
                ) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }


    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(
                        selectedDate.formatted(
                            .dateTime
                                .weekday(.wide)
                        )
                    )
                    .font(
                        .largeTitle.weight(
                            .semibold
                        )
                    )

                    Text(
                        selectedDate.formatted(
                            .dateTime
                                .month(.wide)
                                .day()
                                .year()
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }

                Spacer()

                if calendar.isDateInToday(
                    selectedDate
                ) {

                    Text("TODAY")
                        .font(
                            .caption.weight(
                                .bold
                            )
                        )
                        .foregroundStyle(
                            coral
                        )
                        .padding(
                            .horizontal,
                            10
                        )
                        .padding(
                            .vertical,
                            6
                        )
                        .background(
                            coral.opacity(
                                0.1
                            )
                        )
                        .clipShape(
                            Capsule()
                        )
                }
            }
        }
        .padding(.top, 12)
    }


    // MARK: - Summary

    private var summary: some View {

        HStack(spacing: 12) {

            SummaryCard(
                value:
                    "\(dayEvents.count)",
                label:
                    dayEvents.count == 1
                    ? "event"
                    : "events"
            )

            SummaryCard(
                value:
                    formattedBusyTime,
                label:
                    "scheduled"
            )

            if !dayEvents.isEmpty {

                SummaryCard(
                    value:
                        "\(linkedEventCount)",
                    label:
                        linkedEventCount == 1
                        ? "linked"
                        : "linked"
                )
            }
        }
    }


    private var linkedEventCount: Int {

        dayEvents.filter {
            $0.taskID != nil ||
            $0.goalID != nil
        }.count
    }


    // MARK: - Busy Time

    private var formattedBusyTime: String {

        let totalSeconds =
            dayEvents.reduce(0.0) {
                total,
                event in

                let dayStart =
                    calendar.startOfDay(
                        for: selectedDate
                    )

                let dayEnd =
                    calendar.date(
                        byAdding: .day,
                        value: 1,
                        to: dayStart
                    ) ?? selectedDate

                let start = max(
                    event.startDate,
                    dayStart
                )

                let end = min(
                    event.endDate,
                    dayEnd
                )

                return total +
                    max(
                        0,
                        end.timeIntervalSince(
                            start
                        )
                    )
            }

        let hours =
            Int(
                totalSeconds / 3600
            )

        let minutes =
            Int(
                (
                    totalSeconds
                        .truncatingRemainder(
                            dividingBy: 3600
                        )
                ) / 60
            )

        if hours > 0 {

            return minutes > 0
                ? "\(hours)h \(minutes)m"
                : "\(hours)h"
        }

        return "\(minutes)m"
    }


    // MARK: - Timeline

    private var timeline: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("SCHEDULE")
                .font(
                    .caption.weight(
                        .semibold
                    )
                )
                .foregroundStyle(
                    .secondary
                )
                .tracking(1)

            if dayEvents.isEmpty {

                emptyState

            } else {

                ForEach(
                    dayEvents
                ) { event in

                    NavigationLink {

                        EventEditorView(
                            event: event
                        )

                    } label: {

                        DayOverviewEvent(
                            event: event,
                            selectedDate:
                                selectedDate,
                            task:
                                task(for: event),
                            goal:
                                goal(for: event),
                            coral: coral
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }


    // MARK: - Empty State

    private var emptyState: some View {

        VStack(spacing: 10) {

            Image(
                systemName:
                    "calendar.badge.checkmark"
            )
            .font(
                .system(size: 30)
            )
            .foregroundStyle(
                coral
            )

            Text("Nothing scheduled")
                .font(.headline)

            Text(
                calendar.isDateInToday(
                    selectedDate
                )
                ? "You've got a clear day."
                : "There's nothing planned for this day."
            )
            .foregroundStyle(
                .secondary
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(
            .vertical,
            50
        )
    }


    // MARK: - Task / Goal Lookup

    private func task(
        for event: CalendarEvent
    ) -> TaskItem? {

        guard let taskID =
                event.taskID
        else {
            return nil
        }

        return tasks.first {
            $0.id == taskID
        }
    }


    private func goal(
        for event: CalendarEvent
    ) -> Goal? {

        // Prefer the task's goal.

        if let task =
            task(for: event),
           let goalID =
            task.goalID {

            return goals.first {
                $0.id == goalID
            }
        }

        // Otherwise use the event's
        // directly-linked goal.

        guard let goalID =
                event.goalID
        else {
            return nil
        }

        return goals.first {
            $0.id == goalID
        }
    }


    // MARK: - Event Date Logic

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

        let dayStart =
            calendar.startOfDay(
                for: date
            )

        guard let dayEnd =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: dayStart
                )
        else {
            return false
        }

        return event.startDate < dayEnd &&
               event.endDate > dayStart
    }


    // MARK: - Summary Card

    private struct SummaryCard:
        View {

        let value: String
        let label: String

        var body: some View {

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text(value)
                    .font(
                        .title2.weight(
                            .semibold
                        )
                    )

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(16)
            .background(
                .background
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
    }


    // MARK: - Event Card

    private struct DayOverviewEvent:
        View {

        let event: CalendarEvent
        let selectedDate: Date
        let task: TaskItem?
        let goal: Goal?
        let coral: Color

        private let calendar =
            Calendar.current

        var body: some View {

            HStack(
                alignment: .top,
                spacing: 14
            ) {

                // Time

                VStack(
                    alignment: .trailing,
                    spacing: 3
                ) {

                    if event.isAllDay {

                        Text("ALL DAY")
                            .font(
                                .caption.weight(
                                    .semibold
                                )
                            )

                    } else {

                        Text(
                            event.startDate.formatted(
                                date: .omitted,
                                time: .shortened
                            )
                        )
                        .font(
                            .subheadline.weight(
                                .medium
                            )
                        )
                    }
                }
                .frame(
                    width: 72,
                    alignment: .trailing
                )


                // Colour bar

                RoundedRectangle(
                    cornerRadius: 3
                )
                .fill(
                    eventColor
                )
                .frame(width: 4)


                // Details

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    HStack {

                        Text(event.title)
                            .font(.headline)

                        Spacer()

                        Image(
                            systemName:
                                "chevron.right"
                        )
                        .font(
                            .caption.weight(
                                .bold
                            )
                        )
                        .foregroundStyle(
                            .tertiary
                        )
                    }


                    if !event.location.isEmpty {

                        Label(
                            event.location,
                            systemImage:
                                "location"
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    // Task

                    if let task {

                        Label(
                            task.name,
                            systemImage:
                                "checkmark.circle"
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .primary
                        )
                    }


                    // Goal

                    if let goal {

                        Label(
                            goal.name,
                            systemImage:
                                "target"
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    if !event.notes.isEmpty {

                        Text(event.notes)
                            .font(
                                .subheadline
                            )
                            .foregroundStyle(
                                .secondary
                            )
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(
                .background
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }


        private var eventColor: Color {

            switch event.eventColor {

            case "blue":
                return .blue

            case "green":
                return .green

            case "orange":
                return .orange

            case "purple":
                return .purple

            case "red":
                return .red

            case "yellow":
                return .yellow

            case "pink":
                return .pink

            case "teal":
                return .teal

            default:
                return coral
            }
        }
    }
}
