//
//  MascotState.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import Foundation

// MARK: - Mascot Expression

enum MascotExpression: String {

    case deadpan
    case smug
    case really
    case eyeRoll
    case mockEnthusiasm
    case awkward
    case slowClap
    case quip
    case exasperated
    case mockShock
    case wink
    case confident
    case warm
    case concerned
    case listening
    case encouraging
    case proud
    case happy
    case celebrating
    case sympathetic
    case determined
    case thinking
    case hello
    case walking

    var imageName: String {
        switch self {
        case .deadpan: return "01-deadpan"
        case .smug: return "02-smug"
        case .really: return "03-really"
        case .eyeRoll: return "04-eye-roll"
        case .mockEnthusiasm: return "05-mock-enthusiasm"
        case .awkward: return "06-awkward"
        case .slowClap: return "07-slow-clap"
        case .quip: return "08-quip"
        case .exasperated: return "09-exasperated"
        case .mockShock: return "10-mock-shock"
        case .wink: return "11-wink"
        case .confident: return "12-confident"
        case .warm: return "13-warm"
        case .concerned: return "14-concerned"
        case .listening: return "15-listening"
        case .encouraging: return "16-encouraging"
        case .proud: return "17-proud"
        case .happy: return "18-happy"
        case .celebrating: return "19-celebrating"
        case .sympathetic: return "20-sympathetic"
        case .determined: return "21-determined"
        case .thinking: return "22-thinking"
        case .hello: return "23-hello"
        case .walking: return "24-walking"
        }
    }

    var displayName: String {
        switch self {
        case .deadpan: return "Deadpan"
        case .smug: return "Smug"
        case .really: return "Really?"
        case .eyeRoll: return "Eye Roll"
        case .mockEnthusiasm: return "Mock Enthusiasm"
        case .awkward: return "Awkward"
        case .slowClap: return "Slow Clap"
        case .quip: return "Quip"
        case .exasperated: return "Exasperated"
        case .mockShock: return "Mock Shock"
        case .wink: return "Wink"
        case .confident: return "Confident"
        case .warm: return "Warm"
        case .concerned: return "Concerned"
        case .listening: return "Listening"
        case .encouraging: return "Encouraging"
        case .proud: return "Proud"
        case .happy: return "Happy"
        case .celebrating: return "Celebrating"
        case .sympathetic: return "Sympathetic"
        case .determined: return "Determined"
        case .thinking: return "Thinking"
        case .hello: return "Hello"
        case .walking: return "Walking"
        }
    }
}

// MARK: - Mascot Event

enum MascotEvent {

    // MARK: App & Journey

    case openedApp
    case completedOnboarding
    case startedJourney
    case startedDay
    case finishedDay

    // MARK: Daily Progress

    case completedDay
    case missedDay
    case dayOverdue
    case upcomingDay
    case returnedAfterAbsence

    // MARK: Streaks

    case streakStarted
    case streakExtended
    case streakBroken
    case personalBestReached

    // MARK: Milestones

    case firstDayCompleted
    case firstWeekCompleted
    case milestoneReached
    case halfwayReached
    case finalWeekStarted
    case finalDay
    case journeyCompleted

    // MARK: Goals

    case goalAdded
    case goalCompleted
    case goalMissed
    case goalUpdated

    // MARK: Check-ins & Notes

    case checkInStarted
    case checkInCompleted
    case noteAdded
    case noteUpdated
    case noteDeleted

    // MARK: Calendar & Progress

    case calendarInsight
    case progressInsight
    case consistencyImproved
    case consistencyDropped

    // MARK: Mascot Interaction

    case mascotOpened
    case askedQuestion
    case conversationStarted
    case helpRequested

    // MARK: General State

    case struggling
    case doingWell
}

// MARK: - Mascot Context

struct MascotContext {

    var currentDay: Int
    var currentStreak: Int
    var longestStreak: Int

    var completedDays: Int
    var missedDays: Int

    var progressPercentage: Double

    var milestoneName: String?
    var calendarInsight: String?

    var isFirstDay: Bool
    var returnedAfterAbsence: Bool

    init(
        currentDay: Int = 1,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        completedDays: Int = 0,
        missedDays: Int = 0,
        progressPercentage: Double = 0,
        milestoneName: String? = nil,
        calendarInsight: String? = nil,
        isFirstDay: Bool = false,
        returnedAfterAbsence: Bool = false
    ) {
        self.currentDay = currentDay
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.completedDays = completedDays
        self.missedDays = missedDays
        self.progressPercentage = progressPercentage
        self.milestoneName = milestoneName
        self.calendarInsight = calendarInsight
        self.isFirstDay = isFirstDay
        self.returnedAfterAbsence = returnedAfterAbsence
    }
}

// MARK: - Mascot State

struct MascotState {

    var expression: MascotExpression
    var event: MascotEvent?
    var message: String
    var context: MascotContext
    var responseMode: MascotResponseMode

    init(
        expression: MascotExpression = .hello,
        event: MascotEvent? = nil,
        message: String = "",
        context: MascotContext = MascotContext(),
        responseMode: MascotResponseMode = .local
    ) {
        self.expression = expression
        self.event = event
        self.message = message
        self.context = context
        self.responseMode = responseMode
    }
}
