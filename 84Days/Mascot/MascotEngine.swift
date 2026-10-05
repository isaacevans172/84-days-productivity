//
//  MascotEngine.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import Foundation

struct MascotEngine {

    static func state(
        for event: MascotEvent,
        context: MascotContext = MascotContext()
    ) -> MascotState {

        switch event {

        // MARK: App & Journey

        case .openedApp:

            if context.isFirstDay {
                return state(
                    .hello,
                    event,
                    "Alright. Let's see what you've got.",
                    context
                )
            }

            if context.currentStreak >= 7 {
                return state(
                    .confident,
                    event,
                    "Look who's still going.",
                    context
                )
            }

            return state(
                .happy,
                event,
                "Welcome back.",
                context
            )

        case .completedOnboarding:

            return state(
                .happy,
                event,
                "Well, you're officially stuck with me now.",
                context
            )

        case .startedJourney:

            return state(
                .determined,
                event,
                "Day one. No pressure.",
                context
            )

        case .startedDay:

            return state(
                .walking,
                event,
                "Alright. Let's get moving.",
                context
            )

        case .finishedDay:

            return state(
                .proud,
                event,
                "That's today sorted.",
                context
            )

        // MARK: Daily Progress

        case .completedDay:

            if context.currentDay == 84 {
                return state(
                    .celebrating,
                    event,
                    "Eighty-four days. You actually did it.",
                    context
                )
            }

            if context.currentStreak >= 30 {
                return state(
                    .celebrating,
                    event,
                    "Thirty days?! Okay, you're actually serious.",
                    context
                )
            }

            if context.currentStreak >= 7 {
                return state(
                    .proud,
                    event,
                    "Seven days straight. Not bad.",
                    context
                )
            }

            return state(
                .happy,
                event,
                "Another one done.",
                context
            )

        case .missedDay:

            if context.currentStreak >= 7 {
                return state(
                    .sympathetic,
                    event,
                    "Well... there goes the streak. Doesn't mean the journey's over.",
                    context
                )
            }

            return state(
                .deadpan,
                event,
                "Well... that happened.",
                context
            )

        case .dayOverdue:

            return state(
                .concerned,
                event,
                "It's getting a little late. You still have time.",
                context
            )

        case .upcomingDay:

            return state(
                .encouraging,
                event,
                "Tomorrow's waiting.",
                context
            )

        case .returnedAfterAbsence:

            return state(
                .warm,
                event,
                "Look who's back. No judgement.",
                context
            )

        // MARK: Streaks

        case .streakStarted:

            return state(
                .encouraging,
                event,
                "And we're off.",
                context
            )

        case .streakExtended:

            if context.currentStreak >= 30 {
                return state(
                    .celebrating,
                    event,
                    "Thirty days. That's getting ridiculous.",
                    context
                )
            }

            if context.currentStreak >= 14 {
                return state(
                    .smug,
                    event,
                    "Two weeks. I might have to start taking you seriously.",
                    context
                )
            }

            if context.currentStreak >= 7 {
                return state(
                    .proud,
                    event,
                    "A whole week. Nice.",
                    context
                )
            }

            return state(
                .happy,
                event,
                "Streak's alive.",
                context
            )

        case .streakBroken:

            return state(
                .deadpan,
                event,
                "And there goes the streak. Rude.",
                context
            )

        case .personalBestReached:

            return state(
                .smug,
                event,
                "New personal best. I suppose I should be impressed.",
                context
            )

        // MARK: Milestones

        case .firstDayCompleted:

            return state(
                .proud,
                event,
                "Day one officially done.",
                context
            )

        case .firstWeekCompleted:

            return state(
                .celebrating,
                event,
                "One week down. That's a pretty good start.",
                context
            )

        case .milestoneReached:

            return state(
                .celebrating,
                event,
                milestoneMessage(context),
                context
            )

        case .halfwayReached:

            return state(
                .mockShock,
                event,
                "Wait. We're already halfway through this thing?",
                context
            )

        case .finalWeekStarted:

            return state(
                .determined,
                event,
                "Final week. Now would be a terrible time to get lazy.",
                context
            )

        case .finalDay:

            return state(
                .celebrating,
                event,
                "The final day. Let's finish this properly.",
                context
            )

        case .journeyCompleted:

            return state(
                .celebrating,
                event,
                "Eighty-four days. That's one hell of a finish.",
                context
            )

        // MARK: Goals

        case .goalAdded:

            return state(
                .encouraging,
                event,
                "New goal? Alright, let's see what you've got.",
                context
            )

        case .goalCompleted:

            return state(
                .proud,
                event,
                "Goal done. Lovely stuff.",
                context
            )

        case .goalMissed:

            return state(
                .sympathetic,
                event,
                "Didn't happen today. Tomorrow still exists.",
                context
            )

        case .goalUpdated:

            return state(
                .thinking,
                event,
                "Tweaking the plan. Fair enough.",
                context
            )

        // MARK: Check-ins & Notes

        case .checkInStarted:

            return state(
                .listening,
                event,
                "Alright. What's going on?",
                context
            )

        case .checkInCompleted:

            return state(
                .warm,
                event,
                "Check-in done. Good to know where you're at.",
                context
            )

        case .noteAdded:

            return state(
                .thinking,
                event,
                "Noted. Literally.",
                context
            )

        case .noteUpdated:

            return state(
                .thinking,
                event,
                "Making some edits, I see.",
                context
            )

        case .noteDeleted:

            return state(
                .really,
                event,
                "And that note is apparently history.",
                context
            )

        // MARK: Calendar & Progress

        case .calendarInsight:

            return state(
                .thinking,
                event,
                context.calendarInsight ?? "I've been looking at your calendar.",
                context
            )

        case .progressInsight:

            if context.progressPercentage >= 75 {
                return state(
                    .proud,
                    event,
                    "You're getting seriously close now.",
                    context
                )
            }

            if context.progressPercentage >= 50 {
                return state(
                    .confident,
                    event,
                    "More than halfway there.",
                    context
                )
            }

            return state(
                .encouraging,
                event,
                "Every day counts.",
                context
            )

        case .consistencyImproved:

            return state(
                .proud,
                event,
                "Your consistency is looking better.",
                context
            )

        case .consistencyDropped:

            return state(
                .concerned,
                event,
                "We've slipped a little. Worth getting back on track.",
                context
            )

        // MARK: Mascot Interaction

        case .mascotOpened:

            return state(
                .happy,
                event,
                "Oh, you came to see me.",
                context
            )

        case .askedQuestion:

            return state(
                .listening,
                event,
                "I'm listening.",
                context
            )

        case .conversationStarted:

            return state(
                .listening,
                event,
                "Alright, talk to me.",
                context
            )

        case .helpRequested:

            return state(
                .encouraging,
                event,
                "Alright. Let's figure this out.",
                context
            )

        // MARK: General State

        case .struggling:

            return state(
                .sympathetic,
                event,
                "Alright. Let's take this one step at a time.",
                context
            )

        case .doingWell:

            return state(
                .confident,
                event,
                "You're doing pretty well, actually.",
                context
            )
        }
    }

    // MARK: - Helpers

    private static func state(
        _ expression: MascotExpression,
        _ event: MascotEvent,
        _ message: String,
        _ context: MascotContext
    ) -> MascotState {

        MascotState(
            expression: expression,
            event: event,
            message: message,
            context: context
        )
    }

    private static func milestoneMessage(
        _ context: MascotContext
    ) -> String {

        guard let milestone = context.milestoneName else {
            return "Okay, that's worth celebrating."
        }

        return "\(milestone)? Okay, that's worth celebrating."
    }
}
