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

    // MARK: - Identity

    var id: UUID

    var title: String
    var startDate: Date
    var endDate: Date

    var location: String
    var locationAddress: String?

    var latitude: Double?
    var longitude: Double?

    var notes: String
    var calendarName: String

    var isAllDay: Bool

    var eventColor: String

    var taskID: UUID?
    var goalID: UUID?

    var reminderMinutes: Int?
    var repeatRule: String

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialiser

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        location: String = "",
        locationAddress: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String = "",
        calendarName: String = "84Days",
        isAllDay: Bool = false,
        taskID: UUID? = nil,
        goalID: UUID? = nil,
        reminderMinutes: Int? = nil,
        repeatRule: String = "Never",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        eventColor: String = "Coral"
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate

        self.location = location
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude

        self.notes = notes
        self.calendarName = calendarName
        self.isAllDay = isAllDay

        self.taskID = taskID
        self.goalID = goalID

        self.reminderMinutes = reminderMinutes
        self.repeatRule = repeatRule

        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.eventColor = eventColor
    }
}


// MARK: - Recurrence

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
