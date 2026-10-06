//
//  DataModels.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//

import Foundation
import SwiftData


// MARK: - Task Priority

enum TaskPriority: String, Codable {
    case low
    case medium
    case high
}


// MARK: - Local User Profile

@Model
final class LocalUserProfile {
    var id: UUID

    var firstName: String
    var lastName: String
    var email: String
    var avatar: String?

    var dailyGoal: Int

    var currentStreak: Int
    var longestStreak: Int

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        avatar: String? = nil,
        dailyGoal: Int = 3,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatar = avatar
        self.dailyGoal = dailyGoal
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


// MARK: - Task

@Model
final class TaskItem{
    var id: UUID

    var name: String
    var notes: String?

    var isComplete: Bool
    var priority: TaskPriority

    var icon: String
    var category: String?

    var dueDate: Date?
    var completedAt: Date?

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        notes: String? = nil,
        isComplete: Bool = false,
        priority: TaskPriority = .medium,
        icon: String = "checkmark.circle",
        category: String? = nil,
        dueDate: Date? = nil,
        completedAt: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.isComplete = isComplete
        self.priority = priority
        self.icon = icon
        self.category = category
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


// MARK: - Calendar Event

@Model
final class CalendarEvent {
    var id: UUID

    var title: String
    var notes: String?

    var startDate: Date
    var endDate: Date

    var isAllDay: Bool

    // MapKit location information
    var locationName: String?
    var locationAddress: String?
    var latitude: Double?
    var longitude: Double?

    // Recurrence
    var recurrenceRule: String?

    // Reminder
    var reminderMinutesBefore: Int?

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        locationName: String? = nil,
        locationAddress: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        recurrenceRule: String? = nil,
        reminderMinutesBefore: Int? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.recurrenceRule = recurrenceRule
        self.reminderMinutesBefore = reminderMinutesBefore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


// MARK: - Reflection

@Model
final class Reflection {
    var id: UUID

    var date: Date
    var rating: Int

    var note: String?

    var completedTasks: Int
    var focusMinutes: Int

    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = .now,
        rating: Int,
        note: String? = nil,
        completedTasks: Int = 0,
        focusMinutes: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.rating = min(max(rating, 1), 5)
        self.note = note
        self.completedTasks = completedTasks
        self.focusMinutes = focusMinutes
        self.createdAt = createdAt
    }
}


// MARK: - Focus Session

@Model
final class FocusSession {
    var id: UUID

    var startDate: Date
    var duration: TimeInterval
    var breakTime: TimeInterval

    var completed: Bool

    // Optional task associated with this session
    var taskID: UUID?

    var createdAt: Date

    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        duration: TimeInterval,
        breakTime: TimeInterval = 0,
        completed: Bool = false,
        taskID: UUID? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.startDate = startDate
        self.duration = duration
        self.breakTime = breakTime
        self.completed = completed
        self.taskID = taskID
        self.createdAt = createdAt
    }
}


// MARK: - Habit

@Model
final class Habit {
    var id: UUID

    var name: String
    var icon: String

    var targetPerWeek: Int

    var currentStreak: Int
    var longestStreak: Int

    var createdAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "flame",
        targetPerWeek: Int = 7,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        createdAt: Date = .now,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.targetPerWeek = targetPerWeek
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.createdAt = createdAt
        self.isActive = isActive
    }
}


// MARK: - Habit Completion

@Model
final class HabitCompletion {
    var id: UUID

    var habitID: UUID
    var date: Date

    init(
        id: UUID = UUID(),
        habitID: UUID,
        date: Date = .now
    ) {
        self.id = id
        self.habitID = habitID
        self.date = date
    }
}


// MARK: - Reminder

@Model
final class Reminder {
    var id: UUID

    var title: String
    var date: Date

    var isComplete: Bool

    // Optional links to other objects
    var taskID: UUID?
    var eventID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        isComplete: Bool = false,
        taskID: UUID? = nil,
        eventID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.isComplete = isComplete
        self.taskID = taskID
        self.eventID = eventID
    }
}
