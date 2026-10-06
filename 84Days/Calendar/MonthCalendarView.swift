//
//  MonthCalendarView.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//

import SwiftUI
import SwiftData

struct MonthCalendarView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date

    @Query(sort: \CalendarEvent.startDate)
    private var events: [CalendarEvent]

    private let calendar = Calendar.current

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    @State private var displayedMonth = Date()

    // MARK: - Month Dates

    private var monthDates: [Date] {

        guard let interval =
                calendar.dateInterval(
                    of: .month,
                    for: displayedMonth
                )
        else {
            return []
        }

        let firstWeekday =
            calendar.component(
                .weekday,
                from: interval.start
            )

        let leadingDays =
            firstWeekday -
            calendar.firstWeekday

        let adjustedLeadingDays =
            leadingDays >= 0
            ? leadingDays
            : leadingDays + 7

        let daysInMonth =
            calendar.range(
                of: .day,
                in: .month,
                for: displayedMonth
            )?.count ?? 0

        let totalCells =
            adjustedLeadingDays +
            daysInMonth

        let cellCount =
            Int(
                ceil(
                    Double(totalCells) / 7.0
                )
            ) * 7

        guard let gridStart =
                calendar.date(
                    byAdding: .day,
                    value: -adjustedLeadingDays,
                    to: interval.start
                )
        else {
            return []
        }

        return (0..<cellCount).compactMap {

            calendar.date(
                byAdding: .day,
                value: $0,
                to: gridStart
            )
        }
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    monthHeader

                    weekdayHeader

                    calendarGrid

                    selectedDaySummary
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }

            .background(
                Color(.systemBackground)
            )

            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Today") {
                        goToToday()
                    }
                    .foregroundStyle(coral)
                }
            }
        }

        .onAppear {

            displayedMonth = selectedDate
        }
    }


    // MARK: - Header

    private var monthHeader: some View {

        HStack {

            Button {

                changeMonth(by: -1)

            } label: {

                Image(
                    systemName:
                        "chevron.left"
                )
                .frame(
                    width: 40,
                    height: 40
                )
            }

            Spacer()

            VStack(spacing: 2) {

                Text(
                    displayedMonth.formatted(
                        .dateTime
                            .month(.wide)
                            .year()
                    )
                )
                .font(
                    .title2.weight(
                        .semibold
                    )
                )

                let monthEventCount =
                    events.filter {
                        eventOccursOnDate(
                            $0,
                            date: $0.startDate
                        ) &&
                        calendar.isDate(
                            $0.startDate,
                            equalTo: displayedMonth,
                            toGranularity: .month
                        )
                    }.count

                if monthEventCount > 0 {

                    Text(
                        "\(monthEventCount) event\(monthEventCount == 1 ? "" : "s")"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {

                changeMonth(by: 1)

            } label: {

                Image(
                    systemName:
                        "chevron.right"
                )
                .frame(
                    width: 40,
                    height: 40
                )
            }
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 16)
    }


    // MARK: - Weekday Header

    private var weekdayHeader: some View {

        HStack(spacing: 0) {

            ForEach(
                weekdaySymbols,
                id: \.self
            ) { symbol in

                Text(symbol)
                    .font(
                        .caption.weight(
                            .semibold
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .frame(
                        maxWidth: .infinity
                    )
            }
        }
        .padding(.bottom, 10)
    }

    private var weekdaySymbols: [String] {

        let symbols =
            calendar.shortStandaloneWeekdaySymbols

        let first =
            calendar.firstWeekday - 1

        return Array(
            symbols[first...] +
            symbols[..<first]
        )
    }


    // MARK: - Calendar Grid

    private var calendarGrid: some View {

        LazyVGrid(
            columns: Array(
                repeating:
                    GridItem(.flexible()),
                count: 7
            ),
            spacing: 14
        ) {

            ForEach(
                monthDates,
                id: \.self
            ) { date in

                monthDay(date)
            }
        }
    }


    // MARK: - Month Day

    private func monthDay(
        _ date: Date
    ) -> some View {

        let isCurrentMonth =
            calendar.isDate(
                date,
                equalTo: displayedMonth,
                toGranularity: .month
            )

        let isSelected =
            calendar.isDate(
                date,
                inSameDayAs: selectedDate
            )

        let isToday =
            calendar.isDateInToday(date)

        let dayEvents =
            eventsForDate(date)

        return Button {

            withAnimation(
                .easeInOut(
                    duration: 0.15
                )
            ) {

                selectedDate = date
            }

            if !isCurrentMonth {

                displayedMonth = date
            }

        } label: {

            VStack(spacing: 5) {

                Text(
                    date.formatted(
                        .dateTime.day()
                    )
                )
                .font(
                    .system(
                        size: 16,
                        weight:
                            isSelected
                            ? .semibold
                            : .regular
                    )
                )
                .foregroundStyle(

                    isSelected
                    ? .white
                    : isCurrentMonth
                    ? .primary
                    : .secondary.opacity(0.45)
                )
                .frame(
                    width: 38,
                    height: 38
                )
                .background {

                    Circle()
                        .fill(
                            isSelected
                            ? coral
                            : .clear
                        )
                }

                eventDots(
                    dayEvents
                )

                if isToday &&
                    !isSelected {

                    Circle()
                        .fill(coral)
                        .frame(
                            width: 3,
                            height: 3
                        )
                }
            }
            .frame(
                maxWidth: .infinity
            )
        }
        .buttonStyle(.plain)
    }


    // MARK: - Event Dots

    @ViewBuilder
    private func eventDots(
        _ dayEvents: [CalendarEvent]
    ) -> some View {

        if dayEvents.isEmpty {

            Color.clear
                .frame(
                    width: 5,
                    height: 5
                )

        } else {

            HStack(spacing: 3) {

                ForEach(
                    Array(
                        dayEvents.prefix(3)
                    )
                ) { event in

                    Circle()
                        .fill(
                            colorForEvent(
                                event
                            )
                        )
                        .frame(
                            width: 5,
                            height: 5
                        )
                }

                if dayEvents.count > 3 {

                    Text(
                        "+\(dayEvents.count - 3)"
                    )
                    .font(
                        .system(
                            size: 7,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
            .frame(height: 5)
        }
    }


    // MARK: - Selected Day Summary

    private var selectedDaySummary: some View {

        let dayEvents =
            eventsForDate(selectedDate)

        return VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Divider()
                .padding(.top, 20)

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(
                        selectedDate.formatted(
                            .dateTime
                                .weekday(.wide)
                                .month(.wide)
                                .day()
                        )
                    )
                    .font(
                        .headline
                    )

                    Text(
                        dayEvents.isEmpty
                        ? "Nothing scheduled"
                        : "\(dayEvents.count) event\(dayEvents.count == 1 ? "" : "s")"
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }

                Spacer()

                if !dayEvents.isEmpty {

                    Button {

                        dismiss()

                    } label: {

                        Text("View")
                            .font(
                                .subheadline.weight(
                                    .semibold
                                )
                            )
                            .foregroundStyle(
                                coral
                            )
                    }
                }
            }
        }
    }


    // MARK: - Helpers

    private func eventsForDate(
        _ date: Date
    ) -> [CalendarEvent] {

        events.filter {

            eventOccursOnDate(
                $0,
                date: date
            )
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


    private func colorForEvent(
        _ event: CalendarEvent
    ) -> Color {

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


    private func changeMonth(
        by amount: Int
    ) {

        guard let newMonth =
                calendar.date(
                    byAdding: .month,
                    value: amount,
                    to: displayedMonth
                )
        else {
            return
        }

        withAnimation(
            .easeInOut(
                duration: 0.2
            )
        ) {

            displayedMonth = newMonth
        }
    }


    private func goToToday() {

        let today = Date()

        withAnimation(
            .easeInOut(
                duration: 0.2
            )
        ) {

            selectedDate = today
            displayedMonth = today
        }
    }
}
