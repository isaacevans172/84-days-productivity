//
//  ReflectionView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


//
//  ReflectionView.swift
//  84Days
//

import SwiftUI
import SwiftData

struct ReflectionView: View {

    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - Data

    @Query(sort: \Reflection.date, order: .reverse)
    private var reflections: [Reflection]

    @Query
    private var tasks: [TaskItem]

    @Query
    private var focusSessions: [FocusSession]

    // MARK: - State

    @State private var rating: Int = 0
    @State private var note: String = ""
    @State private var showingSavedMessage = false

    // MARK: - Computed Properties

    private var today: Date {
        Calendar.current.startOfDay(for: .now)
    }

    private var todaysTasks: [TaskItem] {
        tasks.filter {
            guard let dueDate = $0.dueDate else {
                return false
            }

            return Calendar.current.isDate(
                dueDate,
                inSameDayAs: today
            )
        }
    }

    private var completedTasksToday: Int {
        todaysTasks.filter(\.isComplete).count
    }

    private var focusMinutesToday: Int {
        focusSessions
            .filter {
                Calendar.current.isDate(
                    $0.startDate,
                    inSameDayAs: today
                )
            }
            .filter(\.completed)
            .reduce(0) { total, session in
                total + Int(session.duration / 60)
            }
    }

    private var todaysReflection: Reflection? {
        reflections.first {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: today
            )
        }
    }

    private var canSave: Bool {
        rating > 0
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                header

                ratingSection

                noteSection

                statsSection

                saveButton

                previousReflections
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
        .onAppear {
            loadTodaysReflection()
        }
        .alert(
            "Reflection Saved",
            isPresented: $showingSavedMessage
        ) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("Your reflection has been saved.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("DAILY REFLECTION")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            Text("How was today?")
                .font(
                    .system(
                        size: 32,
                        weight: .bold
                    )
                )

            Text(
                "Take a moment to look back at what you achieved."
            )
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Rating

    private var ratingSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("HOW ARE YOU FEELING?")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { number in

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            rating = number
                        }
                    } label: {

                        Image(
                            systemName:
                                number <= rating
                                ? "star.fill"
                                : "star"
                        )
                        .font(
                            .system(
                                size: 34,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            number <= rating
                            ? Color(red: 1.0, green: 0.451, blue: 0.349)
                            : .secondary
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(ratingText)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 22
            )
        )
    }

    // MARK: - Rating Text

    private var ratingText: String {
        switch rating {
        case 1:
            return "Not your best day. That's okay."
        case 2:
            return "A rough one, but you kept going."
        case 3:
            return "A solid day. There's room to build."
        case 4:
            return "Great day. You're making progress."
        case 5:
            return "Excellent. You absolutely showed up."
        default:
            return "Tap a star to rate your day."
        }
    }

    // MARK: - Note

    private var noteSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("REFLECTION")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            ZStack(
                alignment: .topLeading
            ) {

                if note.isEmpty {
                    Text("What went well? What could you improve?")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)
                }

                TextEditor(text: $note)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 130)
            }
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("TODAY'S PROGRESS")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {

                statCard(
                    icon: "checkmark.circle.fill",
                    value: "\(completedTasksToday)",
                    title: "Tasks done"
                )

                statCard(
                    icon: "timer",
                    value: "\(focusMinutesToday)m",
                    title: "Focused"
                )
            }
        }
    }

    private func statCard(
        icon: String,
        value: String,
        title: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(
                    Color(
                        red: 1.0,
                        green: 0.451,
                        blue: 0.349
                    )
                )

            Text(value)
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(16)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            saveReflection()
        } label: {

            HStack {
                Image(systemName: "checkmark")

                Text(
                    todaysReflection == nil
                    ? "Save Reflection"
                    : "Update Reflection"
                )
                .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                canSave
                ? Color(
                    red: 1.0,
                    green: 0.451,
                    blue: 0.349
                )
                : Color.gray,
                in: RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
    }

    // MARK: - Previous Reflections

    private var previousReflections: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("PREVIOUS REFLECTIONS")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            if reflections.isEmpty {

                Text("Your reflections will appear here.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

            } else {

                ForEach(reflections) { reflection in

                    reflectionRow(reflection)
                }
            }
        }
    }

    private func reflectionRow(
        _ reflection: Reflection
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Text(
                    reflection.date.formatted(
                        .dateTime
                            .day()
                            .month(.abbreviated)
                            .year()
                    )
                )
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )

                Spacer()

                HStack(spacing: 2) {

                    ForEach(1...5, id: \.self) { number in

                        Image(
                            systemName:
                                number <= reflection.rating
                                ? "star.fill"
                                : "star"
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(
                            number <= reflection.rating
                            ? Color(
                                red: 1.0,
                                green: 0.451,
                                blue: 0.349
                            )
                            : .secondary
                        )
                    }
                }
            }

            if let note = reflection.note,
               !note.isEmpty {

                Text(note)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack(spacing: 16) {

                Label(
                    "\(reflection.completedTasks) tasks",
                    systemImage: "checkmark.circle"
                )

                Label(
                    "\(reflection.focusMinutes)m focus",
                    systemImage: "timer"
                )
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // MARK: - Load

    private func loadTodaysReflection() {

        guard let reflection = todaysReflection else {
            return
        }

        rating = reflection.rating
        note = reflection.note ?? ""
    }

    // MARK: - Save

    private func saveReflection() {

        if let existing = todaysReflection {

            existing.rating = rating
            existing.note = note.isEmpty ? nil : note
            existing.completedTasks = completedTasksToday
            existing.focusMinutes = focusMinutesToday

        } else {

            let reflection = Reflection(
                date: .now,
                rating: rating,
                note: note.isEmpty ? nil : note,
                completedTasks: completedTasksToday,
                focusMinutes: focusMinutesToday
            )

            modelContext.insert(reflection)
        }

        do {
            try modelContext.save()

            showingSavedMessage = true

        } catch {
            print(
                "❌ Failed to save reflection: \(error)"
            )
        }
    }
}

#Preview {
    NavigationStack {
        ReflectionView()
    }
}