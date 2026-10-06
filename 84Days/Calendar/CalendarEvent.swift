//
//  CalendarEvent.swift
//  84Days
//
//  Created by Isaac Evans on 5/10/2026.
//

import Foundation
import SwiftData

@Model
final class CalendarEvent {
    var id: UUID
    
    var title: String
    var startDate: Date
    var endDate: Date
    
    var location: String
    var notes: String
    
    var calendarName: String
    var isAllDay: Bool
    
    // Reminder
    var reminderMinutes: Int?
    
    // Repeat
    var repeatRule: String
    
    init(
        title: String,
        startDate: Date,
        endDate: Date,
        location: String = "",
        notes: String = "",
        calendarName: String = "84Days",
        isAllDay: Bool = false,
        reminderMinutes: Int? = nil,
        repeatRule: String = "Never"
    ) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.calendarName = calendarName
        self.isAllDay = isAllDay
        self.reminderMinutes = reminderMinutes
        self.repeatRule = repeatRule
    }
}

extension CalendarEvent {
    
    func occurs(
        on date: Date,
        calendar: Calendar = .current
    ) -> Bool {
        
        let targetDay = calendar.startOfDay(
            for: date
        )
        
        let eventDay = calendar.startOfDay(
            for: startDate
        )
        
        // The original event.
        if calendar.isDate(
            eventDay,
            inSameDayAs: targetDay
        ) {
            return true
        }
        
        switch repeatRule {
            
        case "Daily":
            return targetDay >= eventDay
            
        case "Weekly":
            guard targetDay >= eventDay else {
                return false
            }
            
            let weekday = calendar.component(
                .weekday,
                from: targetDay
            )
            
            let originalWeekday = calendar.component(
                .weekday,
                from: eventDay
            )
            
            return weekday == originalWeekday
            
        case "Monthly":
            guard targetDay >= eventDay else {
                return false
            }
            
            let day = calendar.component(
                .day,
                from: targetDay
            )
            
            let originalDay = calendar.component(
                .day,
                from: eventDay
            )
            
            return day == originalDay
            
        case "Yearly":
            guard targetDay >= eventDay else {
                return false
            }
            
            let month = calendar.component(
                .month,
                from: targetDay
            )
            
            let day = calendar.component(
                .day,
                from: targetDay
            )
            
            let originalMonth = calendar.component(
                .month,
                from: eventDay
            )
            
            let originalDay = calendar.component(
                .day,
                from: eventDay
            )
            
            return month == originalMonth &&
                   day == originalDay
            
        default:
            return false
        }
    }
}
