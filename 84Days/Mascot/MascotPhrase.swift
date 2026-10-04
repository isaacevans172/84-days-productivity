//
//  MascotPhrase.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import Foundation

// MARK: - Response Mode

enum MascotResponseMode {
    case local
    case hybrid
    case ai
}

// MARK: - Mascot Phrase

struct MascotPhrase {

    let text: String
    let expression: MascotExpression
}

// MARK: - Phrase Library

struct MascotPhraseLibrary {

    static func phrases(
        for event: MascotEvent,
        expression: MascotExpression
    ) -> [String] {

        switch event {

        // MARK: Daily Progress

        case .completedDay:
            return [
                "Another one done.",
                "That's today sorted.",
                "One more for the pile.",
                "Look at you, being productive.",
                "Not bad. Not bad at all.",
                "Day complete. We take those.",
                "Another day survived. Impressive."
            ]

        case .missedDay:
            return [
                "Well... that happened.",
                "Bit of a plot twist.",
                "Okay. Not ideal.",
                "We'll pretend that didn't happen.",
                "One bad day doesn't ruin the whole thing.",
                "Right. Moving on."
            ]

        case .dayOverdue:
            return [
                "It's getting a little late.",
                "Just checking... you haven't forgotten, have you?",
                "The day's not over yet.",
                "There's still time. Just saying."
            ]

        case .upcomingDay:
            return [
                "Tomorrow's waiting.",
                "Fresh day coming up.",
                "Tomorrow looks suspiciously productive.",
                "Get some rest. We've got another one tomorrow."
            ]

        case .returnedAfterAbsence:
            return [
                "Look who's back.",
                "Well, well, well.",
                "Oh hey. Long time no see.",
                "No judgement. You're here now.",
                "I was starting to think you'd forgotten about me."
            ]

        // MARK: Streaks

        case .streakStarted:
            return [
                "And we're off.",
                "That's one. Let's see where this goes.",
                "A streak has entered the chat.",
                "Day one of the streak. Nice."
            ]

        case .streakExtended:
            return [
                "Streak's alive.",
                "Still going.",
                "Another one for the streak.",
                "Okay, consistency. I see you.",
                "We're building something here."
            ]

        case .streakBroken:
            return [
                "And there goes the streak.",
                "The streak has left the building.",
                "Well. That was a good run.",
                "RIP streak. You had a good life.",
                "Okay, dramatic pause. Now we start again."
            ]

        case .personalBestReached:
            return [
                "New personal best.",
                "Okay, that's actually impressive.",
                "New record. I'll allow it.",
                "You've officially beaten yourself.",
                "Personal best unlocked."
            ]

        // MARK: Milestones

        case .firstDayCompleted:
            return [
                "Day one officially done.",
                "And that's the first one.",
                "One down. Eighty-three to go.",
                "Well, you actually started."
            ]

        case .firstWeekCompleted:
            return [
                "One whole week.",
                "Seven days down.",
                "A week already? Not bad.",
                "You've officially made it through week one."
            ]

        case .milestoneReached:
            return [
                "Okay, that's worth celebrating.",
                "Milestone unlocked.",
                "Look at that little achievement.",
                "That's a pretty nice number.",
                "We should probably make a big deal about this."
            ]

        case .halfwayReached:
            return [
                "We're halfway there.",
                "Halfway. Already.",
                "Okay, we're properly committed now.",
                "You've made it through half of this thing."
            ]

        case .finalWeekStarted:
            return [
                "Final week.",
                "Seven days left. Don't get lazy now.",
                "The finish line is getting suspiciously close.",
                "Final stretch."
            ]

        case .finalDay:
            return [
                "Final day.",
                "This is it.",
                "One last one.",
                "Okay. Let's finish this properly."
            ]

        case .journeyCompleted:
            return [
                "Eighty-four days. You actually did it.",
                "That's the whole thing.",
                "Journey complete.",
                "You made it all the way.",
                "Well... look at you."
            ]

        // MARK: Goals

        case .goalAdded:
            return [
                "New goal? Interesting.",
                "Alright, let's see what you've got.",
                "Another goal enters the arena.",
                "Okay. Let's make it happen."
            ]

        case .goalCompleted:
            return [
                "Goal done.",
                "That's one off the list.",
                "Lovely stuff.",
                "Checked off.",
                "Another goal bites the dust."
            ]

        case .goalMissed:
            return [
                "Didn't happen today.",
                "Okay. We try again.",
                "Not every day can be perfect.",
                "We'll get it next time.",
                "One miss isn't the end of the world."
            ]

        case .goalUpdated:
            return [
                "Tweaking the plan.",
                "Making some adjustments, I see.",
                "Fair enough. Plans change.",
                "A little optimisation never hurt."
            ]

        // MARK: Check-ins & Notes

        case .checkInStarted:
            return [
                "Alright. What's going on?",
                "Talk to me.",
                "I'm listening.",
                "Okay. Let's check in."
            ]

        case .checkInCompleted:
            return [
                "Check-in done.",
                "Good. That's worth knowing.",
                "Alright, noted.",
                "Thanks for checking in."
            ]

        case .noteAdded:
            return [
                "Noted. Literally.",
                "Filed away.",
                "I'll remember that.",
                "Adding that to the record."
            ]

        case .noteUpdated:
            return [
                "Making some edits, I see.",
                "Updated.",
                "Fair enough. Revised edition.",
                "Change noted."
            ]

        case .noteDeleted:
            return [
                "And that note is history.",
                "Gone.",
                "Apparently that one didn't make the cut.",
                "Deleted. Poof."
            ]

        // MARK: Calendar & Progress

        case .calendarInsight:
            return [
                "I've been looking at your calendar.",
                "Your calendar has some things to say.",
                "Interesting pattern here.",
                "I found something worth pointing out."
            ]

        case .progressInsight:
            return [
                "Let's see how we're tracking.",
                "Time for a progress check.",
                "I've got some numbers for you.",
                "Let's look at the bigger picture."
            ]

        case .consistencyImproved:
            return [
                "Your consistency is looking better.",
                "Okay, that's some improvement.",
                "You're getting more consistent.",
                "I can see the difference."
            ]

        case .consistencyDropped:
            return [
                "We've slipped a little.",
                "Consistency's taken a small hit.",
                "Bit of a wobble.",
                "Let's get things moving again."
            ]

        // MARK: Mascot Interaction

        case .mascotOpened:
            return [
                "Oh, you came to see me.",
                "Look who's back.",
                "You rang?",
                "Ah. My favourite notification."
            ]

        case .askedQuestion:
            return [
                "I'm listening.",
                "Go on.",
                "Alright, what's the question?",
                "Hit me."
            ]

        case .conversationStarted:
            return [
                "Alright, talk to me.",
                "What's on your mind?",
                "Okay, I'm listening.",
                "Go ahead."
            ]

        case .helpRequested:
            return [
                "Alright. Let's figure this out.",
                "Okay, I'm here.",
                "Let's work through it.",
                "Right. Problem-solving mode."
            ]

        // MARK: General

        case .openedApp:
            return [
                "Welcome back.",
                "There you are.",
                "Back at it.",
                "Alright, what are we doing today?"
            ]

        case .completedOnboarding:
            return [
                "Well, you're officially stuck with me now.",
                "And we're in.",
                "Alright. Let's do this.",
                "Welcome to the chaos."
            ]

        case .startedJourney:
            return [
                "Day one. No pressure.",
                "Alright. Here we go.",
                "This is where it starts.",
                "Let's get this thing moving."
            ]

        case .startedDay:
            return [
                "Alright. Let's get moving.",
                "Here we go.",
                "Let's make today count.",
                "Time to get started."
            ]

        case .finishedDay:
            return [
                "That's today sorted.",
                "Day finished.",
                "And we're done for today.",
                "That's another day in the books."
            ]

        case .struggling:
            return [
                "Alright. One step at a time.",
                "Okay. Let's not make this harder than it needs to be.",
                "Take a breath. We'll work it out.",
                "You're allowed to have a rough day."
            ]

        case .doingWell:
            return [
                "You're doing pretty well, actually.",
                "Okay, I see the progress.",
                "Things are looking good.",
                "You're getting the hang of this."
            ]
        }
    }

    // MARK: - Random Local Phrase

    static func randomPhrase(
        for event: MascotEvent,
        expression: MascotExpression
    ) -> String {

        let available = phrases(
            for: event,
            expression: expression
        )

        return available.randomElement()
            ?? "Alright. Let's keep going."
    }
}
