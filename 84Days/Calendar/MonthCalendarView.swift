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
    private let coral = Color(red: 1.0, green: 0.451, blue: 0.349)
    
    @State private var displayedMonth = Date()
    
    private var monthDates: [Date] {
        guard let interval = calendar.dateInterval(
            of: .month,
            for: displayedMonth
        ) else {
            return []
        }
        
        let firstWeekday = calendar.component(
            .weekday,
            from: interval.start
        )
        
        let leadingDays = firstWeekday - calendar.firstWeekday
        
        let adjustedLeadingDays =
        leadingDays >= 0
        ? leadingDays
        : leadingDays + 7
        
        let daysInMonth = calendar.range(
            of: .day,
            in: .month,
            for: displayedMonth
        )?.count ?? 0
        
        let totalCells = adjustedLeadingDays + daysInMonth
        let cellCount = Int(ceil(Double(totalCells) / 7.0)) * 7
        
        guard let gridStart = calendar.date(
            byAdding: .day,
            value: -adjustedLeadingDays,
            to: interval.start
        ) else {
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                monthHeader
                
                weekdayHeader
                
                calendarGrid
                
                Spacer()
            }
            .padding(.horizontal, 16)
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
            }
        }
        .onAppear {
            displayedMonth = selectedDate
        }
    }
    
    // MARK: Header
    
    private var monthHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text(
                displayedMonth.formatted(
                    .dateTime
                        .month(.wide)
                        .year()
                )
            )
            .font(.headline)
            
            Spacer()
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 40, height: 40)
            }
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 16)
    }
    
    // MARK: Weekday Header
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(
                weekdaySymbols,
                id: \.self
            ) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 10)
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        
        let first = calendar.firstWeekday - 1
        
        return Array(
            symbols[first...] + symbols[..<first]
        )
    }
    
    // MARK: Grid
    
    private var calendarGrid: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible()),
                count: 7
            ),
            spacing: 12
        ) {
            ForEach(monthDates, id: \.self) { date in
                monthDay(date)
            }
        }
    }
    
    private func monthDay(_ date: Date) -> some View {
        let isCurrentMonth = calendar.isDate(
            date,
            equalTo: displayedMonth,
            toGranularity: .month
        )
        
        let isSelected = calendar.isDate(
            date,
            inSameDayAs: selectedDate
        )
        
        let isToday = calendar.isDateInToday(date)
        
        let hasEvents = events.contains {
            eventOccursOnDate($0, date: date)
        }
        
        return Button {
            selectedDate = date
            dismiss()
        } label: {
            VStack(spacing: 4) {
                
                Text(
                    date.formatted(
                        .dateTime.day()
                    )
                )
                .font(
                    .system(
                        size: 16,
                        weight: isSelected ? .semibold : .regular
                    )
                )
                .foregroundStyle(
                    isSelected
                    ? Color.white
                    : isCurrentMonth
                    ? Color.primary
                    : Color.secondary.opacity(0.5)
                )
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(
                            isSelected
                            ? coral
                            : .clear
                        )
                }
                
                Circle()
                    .fill(
                        hasEvents
                        ? coral
                        : .clear
                    )
                    .frame(width: 4, height: 4)
                    .opacity(
                        isSelected ? 0 : 1
                    )
                
                Circle()
                    .fill(
                        isToday
                        ? coral
                        : .clear
                    )
                    .frame(width: 3, height: 3)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    private func changeMonth(by amount: Int) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: amount,
            to: displayedMonth
        ) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = newMonth
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
    
}
