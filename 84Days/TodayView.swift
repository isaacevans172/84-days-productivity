//
//  TodayView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI
import SwiftData

struct TodayView: View {

    @Query(
        sort: \TaskItem.dueDate
    )
    private var tasks: [TaskItem]

    @Query(
        sort: \CalendarEvent.startDate
    )
    private var events: [CalendarEvent]

    @Query
    private var goals: [Goal]

    @State private var showingProfile = false

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    private var today: Date {
        Calendar.current.startOfDay(
            for: Date()
        )
    }

    private var todayTasks: [TaskItem] {

        tasks.filter { task in

            guard let dueDate = task.dueDate else {
                return false
            }

            return Calendar.current.isDate(
                dueDate,
                inSameDayAs: today
            )
        }
    }

    private var completedTasks: Int {

        todayTasks.filter {
            $0.isComplete
        }.count
    }

    private var todayEvents: [CalendarEvent] {

        events.filter {
            $0.occurs(
                on: today,
                calendar: .current
            )
        }
    }

    private var currentGoal: Goal? {
        goals.first
    }

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {

                header

                dayProgress

                focusCard

                todaySection

                if let goal = currentGoal {
                    goalCard(goal)
                }

                mascotHint
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(
            Color(.systemBackground)
        )
        .sheet(isPresented: $showingProfile) {
            NavigationStack {
                ProfileView()
            }
        }
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(greeting)
                    .font(.system(
                        size: 13,
                        weight: .medium
                    ))
                    .foregroundStyle(.secondary)

                Text("Today")
                    .font(.system(
                        size: 32,
                        weight: .bold
                    ))
            }

            Spacer()

            Button {
                showingProfile = true
            } label: {

                Image(
                    systemName: "person.circle.fill"
                )
                .font(.system(size: 32))
                .foregroundStyle(coral)
            }
            .buttonStyle(.plain)
        }
    }

    private var greeting: String {

        let hour = Calendar.current.component(
            .hour,
            from: Date()
        )

        switch hour {

        case 5..<12:
            return "Good morning"

        case 12..<17:
            return "Good afternoon"

        case 17..<22:
            return "Good evening"

        default:
            return "Still going?"
        }
    }

    // MARK: - Progress

    private var dayProgress: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                Text("84 DAY JOURNEY")
                    .font(.system(
                        size: 10,
                        weight: .bold
                    ))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Day 1")
                    .font(.system(
                        size: 11,
                        weight: .semibold
                    ))
            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(
                            Color(.tertiarySystemBackground)
                        )

                    Capsule()
                        .fill(coral)
                        .frame(
                            width:
                                geometry.size.width * 0.01
                        )
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Focus Card

    private var focusCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("YOUR FOCUS")
                        .font(.system(
                            size: 10,
                            weight: .bold
                        ))
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    Text(
                        "What matters today?"
                    )
                    .font(.system(
                        size: 21,
                        weight: .bold
                    ))
                }

                Spacer()

                Image(systemName: "target")
                    .font(.system(size: 22))
                    .foregroundStyle(coral)
            }

            Text(
                todayTasks.isEmpty
                ? "You haven't added anything for today yet."
                : "\(completedTasks) of \(todayTasks.count) tasks completed."
            )
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            coral.opacity(0.08),
            in: RoundedRectangle(
                cornerRadius: 20
            )
        )
    }

    // MARK: - Today

    private var todaySection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionTitle(
                "TODAY",
                count: todayTasks.count +
                    todayEvents.count
            )

            ForEach(todayTasks.prefix(4)) {
                taskRow($0)
            }

            ForEach(todayEvents.prefix(4)) {
                eventRow($0)
            }

            if todayTasks.isEmpty &&
                todayEvents.isEmpty {

                Text(
                    "Your day is clear. Add something from Tasks or Calendar."
                )
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
            }
        }
    }

    private func sectionTitle(
        _ title: String,
        count: Int
    ) -> some View {

        HStack {

            Text(title)
                .font(.system(
                    size: 11,
                    weight: .bold
                ))
                .tracking(1)
                .foregroundStyle(.secondary)

            Text("\(count)")
                .font(.system(
                    size: 10,
                    weight: .bold
                ))
                .foregroundStyle(.secondary)
                .padding(
                    .horizontal,
                    7
                )
                .padding(
                    .vertical,
                    4
                )
                .background(
                    Color(.secondarySystemBackground),
                    in: Capsule()
                )

            Spacer()
        }
    }

    // MARK: - Task Row

    private func taskRow(
        _ task: TaskItem
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: task.icon)
                .foregroundStyle(coral)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    coral.opacity(0.1),
                    in: RoundedRectangle(
                        cornerRadius: 9
                    )
                )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(
                    task.name.isEmpty
                    ? "Untitled task"
                    : task.name
                )
                .font(.system(
                    size: 14,
                    weight: .semibold
                ))

                if let dueDate = task.dueDate {

                    Text(
                        dueDate.formatted(
                            .dateTime
                                .hour()
                                .minute()
                        )
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(
                systemName:
                    task.isComplete
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .foregroundStyle(
                task.isComplete
                ? coral
                : .secondary
            )
        }
        .padding(13)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Event Row

    private func eventRow(
        _ event: CalendarEvent
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: "calendar")
                .foregroundStyle(coral)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    coral.opacity(0.1),
                    in: RoundedRectangle(
                        cornerRadius: 9
                    )
                )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(event.title)
                    .font(.system(
                        size: 14,
                        weight: .semibold
                    ))

                Text(
                    event.isAllDay
                    ? "All day"
                    : event.startDate.formatted(
                        .dateTime
                            .hour()
                            .minute()
                    )
                )
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(13)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Goal

    private func goalCard(
        _ goal: Goal
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("LONG-TERM FOCUS")
                .font(.system(
                    size: 10,
                    weight: .bold
                ))
                .tracking(1)
                .foregroundStyle(.secondary)

            HStack {

                Image(systemName: goal.icon)
                    .foregroundStyle(coral)

                Text(goal.name)
                    .font(.system(
                        size: 16,
                        weight: .bold
                    ))

                Spacer()
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // MARK: - Mascot Hint

    private var mascotHint: some View {

        HStack(spacing: 12) {

            Image("18-happy")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 48,
                    height: 48
                )

            Text(
                "Your companion is keeping an eye on things."
            )
            .font(.system(size: 13))
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
}