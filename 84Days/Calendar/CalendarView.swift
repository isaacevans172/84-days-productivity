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
    
    private let calendar = Calendar.current
    
    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )
    
    @Query(sort: \CalendarEvent.startDate)
    private var events: [CalendarEvent]
    
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var showingMonthView = false
    @State private var showingDayOverview = false
    
    @StateObject private var appleCalendar =
        AppleCalendarManager()
    
    private var selectedDayEvents: [CalendarEvent] {
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    header
                    
                    weekSelector
                    
                    eventSection
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                addEventButton
            }
            .sheet(isPresented: $showingAddEvent) {
                EventEditorView(
                    initialDate: selectedDate
                )
            }
            .sheet(isPresented: $showingMonthView) {
                MonthCalendarView(
                    selectedDate: $selectedDate
                )
            }
            .sheet(isPresented: $showingDayOverview) {
                DayOverviewView(
                    selectedDate: selectedDate
                )
            }
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
    
    // MARK: Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            
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
                        
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Button {
                    goToToday()
                } label: {
                    Text("Today")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(coral)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(coral.opacity(0.1))
                        .clipShape(Capsule())
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
                        systemImage: "list.bullet"
                    )
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(coral)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: Week
    
    private var weekSelector: some View {
        HStack(spacing: 4) {
            
            Button {
                moveWeek(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 36, height: 72)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            
            WeekSelector(
                selectedDate: $selectedDate,
                calendar: calendar,
                coral: coral
            )
            
            Button {
                moveWeek(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 36, height: 72)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 18)
    }
    
    // MARK: Events
    
    private var eventSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                
                Text("EVENTS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                
                Spacer()
                
                if !selectedDayEvents.isEmpty {
                    Text("\(selectedDayEvents.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: 84Days Events
            
            if selectedDayEvents.isEmpty &&
                appleCalendar.events.isEmpty {
                
                EmptyCalendarState()
                
            } else {
                
                ForEach(selectedDayEvents) { event in
                    
                    NavigationLink {
                        EventEditorView(event: event)
                    } label: {
                        CalendarEventCard(
                            event: event,
                            selectedDate: selectedDate
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // MARK: Apple Calendar Events
            
            if appleCalendar.isConnected &&
                !appleCalendar.events.isEmpty {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack {
                        
                        Text("APPLE CALENDAR")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        
                        Spacer()
                        
                        Text("\(appleCalendar.events.count)")
                            .font(.caption.weight(.semibold))
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
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
    }
    
    // MARK: Add
    
    private var addEventButton: some View {
        Button {
            showingAddEvent = true
        } label: {
            HStack {
                
                Image(systemName: "plus")
                
                Text("Add Event")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(coral)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
    
    // MARK: Navigation
    
    private func moveWeek(by amount: Int) {
        guard let date = calendar.date(
            byAdding: .day,
            value: amount * 7,
            to: selectedDate
        ) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = date
        }
    }
    
    private func goToToday() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = Date()
        }
    }
    
    // MARK: Apple Calendar
    
    private func loadAppleEvents() {
        
        let dayStart = calendar.startOfDay(
            for: selectedDate
        )
        
        guard let dayEnd = calendar.date(
            byAdding: .day,
            value: 1,
            to: dayStart
        ) else {
            return
        }
        
        appleCalendar.loadEvents(
            from: dayStart,
            to: dayEnd
        )
    }
    
    // MARK: Event Date Logic
    
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
        
        let dayStart = calendar.startOfDay(
            for: date
        )
        
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
    
    // MARK: Week Selector
    
    private struct WeekSelector: View {
        
        @Binding var selectedDate: Date
        
        let calendar: Calendar
        let coral: Color
        
        private var weekDates: [Date] {
            
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
        
        var body: some View {
            
            HStack(spacing: 0) {
                
                ForEach(
                    weekDates,
                    id: \.self
                ) { date in
                    
                    Button {
                        withAnimation(
                            .easeInOut(duration: 0.15)
                        ) {
                            selectedDate = date
                        }
                    } label: {
                        
                        VStack(spacing: 7) {
                            
                            Text(
                                date.formatted(
                                    .dateTime
                                        .weekday(.narrow)
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            
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
                                    inSameDayAs: selectedDate
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
                                            inSameDayAs: selectedDate
                                        )
                                        ? coral
                                        : .clear
                                    )
                            }
                            
                            Circle()
                                .fill(
                                    calendar.isDateInToday(date)
                                    ? coral
                                    : .clear
                                )
                                .frame(
                                    width: 4,
                                    height: 4
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: Event Card
    
    private struct CalendarEventCard: View {
        
        let event: CalendarEvent
        let selectedDate: Date
        
        private let calendar = Calendar.current
        
        var body: some View {
            HStack(spacing: 14) {
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(.secondary)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if event.isAllDay {
                        
                        Label(
                            "All day",
                            systemImage: "sun.max"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        
                    } else {
                        
                        Label(
                            timeDescription,
                            systemImage: "clock"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    
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
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(18)
            .background(
                Color(.secondarySystemBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        
        private var timeDescription: String {
            
            let startsToday = calendar.isDate(
                event.startDate,
                inSameDayAs: selectedDate
            )
            
            let endsToday = calendar.isDate(
                event.endDate,
                inSameDayAs: selectedDate
            )
            
            if startsToday && endsToday {
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
    
    // MARK: Empty State
    
    private struct EmptyCalendarState: View {
        
        var body: some View {
            VStack(spacing: 10) {
                
                Image(systemName: "calendar")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                
                Text("No events")
                    .font(.headline)
                
                Text("Your day is clear.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 45)
        }
    }
}
