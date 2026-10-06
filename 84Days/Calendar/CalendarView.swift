//
//  CalendarView.swift
//  84Days
//
//  Created by Isaac Evans on 5/10/2026.
//

import SwiftUI
import SwiftData
import EventKit

struct CalendarView: View {

    // MARK: - Constants

    private let calendar = Calendar.current

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    // MARK: - Data

    @Query(sort: \CalendarEvent.startDate)
    private var events: [CalendarEvent]

    // MARK: - State

    @State private var selectedDate = Date()

    @State private var showingAddEvent = false
    @State private var showingMonthView = false
    @State private var showingDayOverview = false

    @StateObject private var appleCalendar =
        AppleCalendarManager()

    // MARK: - Current Week

    private var currentWeekDates: [Date] {

        guard let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: selectedDate
        ) else {
            return []
        }

        return (0..<7).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: interval.start
            )
        }
    }

    // MARK: - Agenda Days

    private var agendaDates: [Date] {

        let today = calendar.startOfDay(
            for: Date()
        )

        // If we're looking at the current week,
        // show today first, then following days.
        if currentWeekDates.contains(
            where: {
                calendar.isDate(
                    $0,
                    inSameDayAs: today
                )
            }
        ) {

            return currentWeekDates
                .filter {
                    calendar.startOfDay(for: $0) >= today
                }
                .sorted {
                    if calendar.isDateInToday($0) {
                        return true
                    }

                    if calendar.isDateInToday($1) {
                        return false
                    }

                    return $0 < $1
                }
        }

        // For another week, simply show that week
        // from earliest to latest.
        return currentWeekDates.sorted()
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    header

                    weekSelector

                    upcomingEvents

                    Spacer(
                        minLength: 100
                    )
                }
            }

            .background(
                Color(.systemBackground)
            )

            .navigationBarHidden(true)

            // MARK: Add Event

            .safeAreaInset(edge: .bottom) {

                addEventButton
            }

            // MARK: Sheets

            .sheet(
                isPresented: $showingAddEvent
            ) {

                EventEditorView(
                    initialDate: selectedDate
                )
            }

            .sheet(
                isPresented: $showingMonthView
            ) {

                MonthCalendarView(
                    selectedDate: $selectedDate
                )
            }

            .sheet(
                isPresented: $showingDayOverview
            ) {

                DayOverviewView(
                    selectedDate: selectedDate
                )
            }

            // MARK: Apple Calendar

            .task {

                if !appleCalendar.isConnected {

                    await appleCalendar.requestAccess()
                }

                loadAppleEvents()
            }

            .onChange(of: selectedDate) {

                loadAppleEvents()
            }
        }
    }


    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Button {

                    showingMonthView = true

                } label: {

                    HStack(spacing: 6) {

                        Text(
                            selectedDate.formatted(
                                .dateTime
                                    .month(.wide)
                                    .year()
                            )
                        )

                        Image(
                            systemName:
                                "chevron.down"
                        )
                        .font(
                            .caption.weight(.bold)
                        )
                    }
                    .font(
                        .system(
                            size: 32,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.primary)
                }

                Spacer()

                Button {

                    goToToday()

                } label: {

                    Text("Today")
                        .font(
                            .subheadline.weight(
                                .semibold
                            )
                        )
                        .foregroundStyle(coral)
                        .padding(
                            .horizontal,
                            14
                        )
                        .padding(
                            .vertical,
                            9
                        )
                        .background(
                            coral.opacity(0.1)
                        )
                        .clipShape(
                            Capsule()
                        )
                }
            }

            HStack {

                Text(
                    selectedDate.formatted(
                        .dateTime
                            .weekday(.wide)
                            .month(.wide)
                            .day()
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Spacer()

                Button {

                    showingDayOverview = true

                } label: {

                    Label(
                        "Day overview",
                        systemImage:
                            "list.bullet"
                    )
                    .font(
                        .subheadline.weight(
                            .medium
                        )
                    )
                    .foregroundStyle(coral)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }


    // MARK: - Week Selector

    private var weekSelector: some View {

        HStack(spacing: 4) {

            Button {

                moveWeek(by: -1)

            } label: {

                Image(
                    systemName:
                        "chevron.left"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .frame(
                    width: 36,
                    height: 72
                )
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            WeekSelector(
                selectedDate: $selectedDate,
                calendar: calendar,
                coral: coral,
                events: events
            )

            Button {

                moveWeek(by: 1)

            } label: {

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .frame(
                    width: 36,
                    height: 72
                )
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 18)
    }


    // MARK: - Upcoming Events

    private var upcomingEvents: some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            HStack {

                Text("UPCOMING")
                    .font(
                        .caption.weight(
                            .semibold
                        )
                    )
                    .foregroundStyle(.secondary)
                    .tracking(1)

                Spacer()

                if !eventsForAgenda.isEmpty {

                    Text(
                        "\(eventsForAgenda.count)"
                    )
                    .font(
                        .caption.weight(
                            .semibold
                        )
                    )
                    .foregroundStyle(.secondary)
                }
            }

            ForEach(
                agendaDates,
                id: \.self
            ) { date in

                let dayEvents =
                    eventsForDate(date)

                if !dayEvents.isEmpty {

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        agendaDayHeader(
                            date: date
                        )

                        ForEach(
                            dayEvents
                        ) { event in

                            NavigationLink {

                                EventEditorView(
                                    event: event
                                )

                            } label: {

                                CalendarEventCard(
                                    event: event,
                                    selectedDate: date,
                                    coral: coral
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if eventsForAgenda.isEmpty {

                EmptyCalendarState(
                    isToday:
                        calendar.isDateInToday(
                            selectedDate
                        )
                )
            }

            // Apple Calendar

            if appleCalendar.isConnected &&
                !appleCalendar.events.isEmpty {

                appleCalendarSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
    }


    // MARK: - Agenda Day Header

    private func agendaDayHeader(
        date: Date
    ) -> some View {

        HStack(spacing: 8) {

            if calendar.isDateInToday(date) {

                Circle()
                    .fill(coral)
                    .frame(
                        width: 7,
                        height: 7
                    )
            }

            Text(
                calendar.isDateInToday(date)
                ? "TODAY"
                : date.formatted(
                    .dateTime
                        .weekday(.wide)
                        .month()
                        .day()
                )
                .uppercased()
            )
            .font(
                .caption.weight(
                    .bold
                )
            )
            .foregroundStyle(
                calendar.isDateInToday(date)
                ? coral
                : .secondary
            )
        }
    }


    // MARK: - Apple Calendar

    private var appleCalendarSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Text("APPLE CALENDAR")
                    .font(
                        .caption.weight(
                            .semibold
                        )
                    )
                    .foregroundStyle(.secondary)
                    .tracking(1)

                Spacer()

                Text(
                    "\(appleCalendar.events.count)"
                )
                .font(
                    .caption.weight(
                        .semibold
                    )
                )
                .foregroundStyle(.secondary)
            }

            ForEach(
                appleCalendar.events,
                id: \.eventIdentifier
            ) { event in

                ExternalCalendarEventCard(
                    event: event
                )
            }
        }
        .padding(.top, 8)
    }


    // MARK: - Add Event

    private var addEventButton: some View {

        Button {

            showingAddEvent = true

        } label: {

            HStack {

                Image(
                    systemName: "plus"
                )

                Text("Add Event")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(coral)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
        .padding(
            .horizontal,
            20
        )
        .padding(
            .vertical,
            10
        )
        .background(
            .ultraThinMaterial
        )
    }


    // MARK: - Event Helpers

    private var eventsForAgenda:
        [CalendarEvent] {

        agendaDates.flatMap {
            eventsForDate($0)
        }
    }

    private func eventsForDate(
        _ date: Date
    ) -> [CalendarEvent] {

        events
            .filter {
                eventOccursOnDate(
                    $0,
                    date: date
                )
            }
            .sorted {
                $0.startDate < $1.startDate
            }
    }


    // MARK: - Navigation

    private func moveWeek(
        by amount: Int
    ) {

        guard let date =
                calendar.date(
                    byAdding: .day,
                    value: amount * 7,
                    to: selectedDate
                )
        else {
            return
        }

        withAnimation(
            .easeInOut(duration: 0.2)
        ) {

            selectedDate = date
        }
    }

    private func goToToday() {

        withAnimation(
            .easeInOut(duration: 0.2)
        ) {

            selectedDate = Date()
        }
    }


    // MARK: - Apple Calendar Loading

    private func loadAppleEvents() {

        let dayStart =
            calendar.startOfDay(
                for: selectedDate
            )

        guard let dayEnd =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: dayStart
                )
        else {
            return
        }

        appleCalendar.loadEvents(
            from: dayStart,
            to: dayEnd
        )
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


    // MARK: - Week Selector

    private struct WeekSelector:
        View {

        @Binding var selectedDate: Date

        let calendar: Calendar
        let coral: Color
        let events: [CalendarEvent]

        private var weekDates:
            [Date] {

            guard let interval =
                    calendar.dateInterval(
                        of: .weekOfYear,
                        for: selectedDate
                    )
            else {
                return []
            }

            return (0..<7).compactMap {

                calendar.date(
                    byAdding: .day,
                    value: $0,
                    to: interval.start
                )
            }
        }

        var body: some View {

            HStack(spacing: 0) {

                ForEach(
                    weekDates,
                    id: \.self
                ) { date in

                    Button {

                        withAnimation(
                            .easeInOut(
                                duration: 0.15
                            )
                        ) {

                            selectedDate = date
                        }

                    } label: {

                        VStack(spacing: 5) {

                            Text(
                                date.formatted(
                                    .dateTime
                                        .weekday(
                                            .narrow
                                        )
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )

                            Text(
                                date.formatted(
                                    .dateTime.day()
                                )
                            )
                            .font(
                                .system(
                                    size: 17,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                calendar.isDate(
                                    date,
                                    inSameDayAs:
                                        selectedDate
                                )
                                ? .white
                                : .primary
                            )
                            .frame(
                                width: 42,
                                height: 42
                            )
                            .background {

                                Circle()
                                    .fill(
                                        calendar.isDate(
                                            date,
                                            inSameDayAs:
                                                selectedDate
                                        )
                                        ? coral
                                        : .clear
                                    )
                            }

                            eventDots(
                                for: date
                            )
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        @ViewBuilder
        private func eventDots(
            for date: Date
        ) -> some View {

            let dayEvents =
                events.filter {

                    if $0.repeatRule != "Never" {

                        return $0.occurs(
                            on: date,
                            calendar: calendar
                        )
                    }

                    let dayStart =
                        calendar.startOfDay(
                            for: date
                        )

                    let dayEnd =
                        calendar.date(
                            byAdding: .day,
                            value: 1,
                            to: dayStart
                        ) ?? dayStart

                    return $0.startDate < dayEnd &&
                           $0.endDate > dayStart
                }

            if dayEvents.isEmpty {

                Circle()
                    .fill(.clear)
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
                                eventDotColor(
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

        private func eventDotColor(
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
    }


    // MARK: - Event Card

    private struct CalendarEventCard:
        View {

        let event: CalendarEvent
        let selectedDate: Date
        let coral: Color

        private let calendar =
            Calendar.current

        var body: some View {

            HStack(spacing: 14) {

                RoundedRectangle(
                    cornerRadius: 3
                )
                .fill(
                    eventColor
                )
                .frame(width: 4)

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    HStack {

                        Text(event.title)
                            .font(.headline)
                            .foregroundStyle(
                                .primary
                            )

                        Spacer()

                        if event.taskID != nil {

                            Image(
                                systemName:
                                    "checkmark.circle"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }

                        if event.goalID != nil {

                            Image(
                                systemName:
                                    "target"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }

                    if event.isAllDay {

                        Label(
                            "All day",
                            systemImage:
                                "sun.max"
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )

                    } else {

                        Label(
                            timeDescription,
                            systemImage:
                                "clock"
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
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

                    if !event.notes.isEmpty {

                        Text(event.notes)
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding(18)
            .background(
                Color(
                    .secondarySystemBackground
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
        }

        private var eventColor:
            Color {

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

        private var timeDescription:
            String {

            let startsToday =
                calendar.isDate(
                    event.startDate,
                    inSameDayAs:
                        selectedDate
                )

            let endsToday =
                calendar.isDate(
                    event.endDate,
                    inSameDayAs:
                        selectedDate
                )

            if startsToday &&
                endsToday {

                return "\(event.startDate.formatted(date: .omitted, time: .shortened)) – \(event.endDate.formatted(date: .omitted, time: .shortened))"
            }

            if startsToday {

                return "Starts \(event.startDate.formatted(date: .omitted, time: .shortened))"
            }

            if endsToday {

                return "Until \(event.endDate.formatted(date: .omitted, time: .shortened))"
            }

            return "All day"
        }
    }


    // MARK: - Empty State

    private struct EmptyCalendarState:
        View {

        let isToday: Bool

        var body: some View {

            VStack(spacing: 10) {

                Image(
                    systemName:
                        "calendar.badge.checkmark"
                )
                .font(
                    .system(size: 28)
                )
                .foregroundStyle(
                    .secondary
                )

                Text(
                    isToday
                    ? "Nothing scheduled"
                    : "No events this week"
                )
                .font(.headline)

                Text(
                    isToday
                    ? "Your day is clear."
                    : "Your schedule is looking pretty clear."
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(
                .vertical,
                45
            )
        }
    }
}
