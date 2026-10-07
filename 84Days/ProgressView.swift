//
//  ProgressView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI
import SwiftData

struct ProgressView: View {

    // MARK: - Data

    @Query(
        sort: \TaskItem.createdAt,
        order: .forward
    )
    private var tasks: [TaskItem]

    @Query(
        sort: \Goal.targetDate,
        order: .forward
    )
    private var goals: [Goal]

    // MARK: - Journey

    @AppStorage("journeyStartDate")
    private var journeyStartDate: Double = Date().timeIntervalSince1970

    // MARK: - Styling

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    // MARK: - Journey Calculations

    private var startDate: Date {
        Date(
            timeIntervalSince1970:
                journeyStartDate
        )
    }

    private var currentDay: Int {

        let calendar = Calendar.current

        let start = calendar.startOfDay(
            for: startDate
        )

        let today = calendar.startOfDay(
            for: Date()
        )

        let difference = calendar.dateComponents(
            [.day],
            from: start,
            to: today
        ).day ?? 0

        return min(
            84,
            max(
                1,
                difference + 1
            )
        )
    }

    private var daysRemaining: Int {
        max(
            0,
            84 - currentDay
        )
    }

    private var journeyProgress: Double {

        min(
            1.0,
            max(
                0.0,
                Double(currentDay) / 84.0
            )
        )
    }

    private var journeyPercentage: Int {

        Int(
            journeyProgress * 100
        )
    }

    // MARK: - Task Calculations

    private var completedTasks: Int {

        tasks.filter {
            $0.isComplete
        }.count
    }

    private var openTasks: Int {

        tasks.filter {
            !$0.isComplete
        }.count
    }

    private var taskCompletionRate: Double {

        guard !tasks.isEmpty else {
            return 0
        }

        return Double(completedTasks) /
            Double(tasks.count)
    }

    private var taskCompletionPercentage: Int {

        Int(
            taskCompletionRate * 100
        )
    }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                header

                journeyCard

                activitySection

                completionCard

                goalsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(
            Color(.systemBackground)
        )
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 5
        ) {

            Text("YOUR JOURNEY")
                .font(.system(
                    size: 10,
                    weight: .bold
                ))
                .tracking(1)
                .foregroundStyle(.secondary)

            Text("Progress")
                .font(.system(
                    size: 32,
                    weight: .bold
                ))

            Text(
                "See how far you've come."
            )
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Journey Card

    private var journeyCard: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            HStack(
                alignment: .top
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text("84 DAYS")
                        .font(.system(
                            size: 10,
                            weight: .bold
                        ))
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    Text(
                        "Day \(currentDay) of 84"
                    )
                    .font(.system(
                        size: 24,
                        weight: .bold
                    ))
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 4
                ) {

                    Text(
                        "\(journeyPercentage)%"
                    )
                    .font(.system(
                        size: 25,
                        weight: .bold
                    ))
                    .foregroundStyle(coral)

                    Text("complete")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(
                            Color(
                                .tertiarySystemBackground
                            )
                        )

                    Capsule()
                        .fill(coral)
                        .frame(
                            width:
                                geometry.size.width *
                                journeyProgress
                        )
                }
            }
            .frame(height: 9)

            HStack {

                Label(
                    "\(daysRemaining) days remaining",
                    systemImage: "calendar"
                )

                Spacer()

                Text(
                    startDate.formatted(
                        .dateTime
                            .day()
                            .month(.abbreviated)
                    )
                )
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        .padding(19)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            coral.opacity(0.08),
            in: RoundedRectangle(
                cornerRadius: 22
            )
        )
    }

    // MARK: - Activity

    private var activitySection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionHeader(
                "ACTIVITY"
            )

            HStack(spacing: 10) {

                statisticCard(
                    value: "\(tasks.count)",
                    title: "Total tasks",
                    icon: "checkmark.circle"
                )

                statisticCard(
                    value: "\(completedTasks)",
                    title: "Completed",
                    icon: "checkmark.circle.fill"
                )

                statisticCard(
                    value: "\(openTasks)",
                    title: "Open",
                    icon: "circle"
                )
            }
        }
    }

    private func statisticCard(
        value: String,
        title: String,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 9
        ) {

            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(coral)

            Text(value)
                .font(.system(
                    size: 23,
                    weight: .bold
                ))

            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(14)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 17
            )
        )
    }

    // MARK: - Completion

    private var completionCard: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("TASK COMPLETION")
                        .font(.system(
                            size: 10,
                            weight: .bold
                        ))
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    Text(
                        "\(taskCompletionPercentage)%"
                    )
                    .font(.system(
                        size: 28,
                        weight: .bold
                    ))
                }

                Spacer()

                Image(
                    systemName:
                        "chart.bar.fill"
                )
                .font(.system(size: 23))
                .foregroundStyle(coral)
            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(
                            Color(
                                .tertiarySystemBackground
                            )
                        )

                    Capsule()
                        .fill(coral)
                        .frame(
                            width:
                                geometry.size.width *
                                taskCompletionRate
                        )
                }
            }
            .frame(height: 8)

            Text(
                tasks.isEmpty
                ? "You haven't created any tasks yet."
                : "\(completedTasks) of \(tasks.count) tasks completed."
            )
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 20
            )
        )
    }

    // MARK: - Goals

    private var goalsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 11
        ) {

            sectionHeader(
                "LONG-TERM GOALS"
            )

            if goals.isEmpty {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(
                        "No long-term goals yet."
                    )
                    .font(.system(
                        size: 14,
                        weight: .semibold
                    ))

                    Text(
                        "Your goals will appear here as you add them."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(.secondarySystemBackground),
                    in: RoundedRectangle(
                        cornerRadius: 17
                    )
                )

            } else {

                ForEach(goals) { goal in

                    goalRow(goal)
                }
            }
        }
    }

    private func goalRow(
        _ goal: Goal
    ) -> some View {

        HStack(spacing: 12) {

            Image(
                systemName: goal.icon
            )
            .font(.system(size: 17))
            .foregroundStyle(coral)
            .frame(
                width: 38,
                height: 38
            )
            .background(
                coral.opacity(0.10),
                in: RoundedRectangle(
                    cornerRadius: 11
                )
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(goal.name)
                    .font(.system(
                        size: 14,
                        weight: .semibold
                    ))

                if let category = goal.category,
                   !category.isEmpty {

                    Text(category)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                if let targetDate = goal.targetDate {

                    Text(
                        "Target: " +
                        targetDate.formatted(
                            .dateTime
                                .day()
                                .month(.abbreviated)
                                .year()
                        )
                    )
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(
                systemName: "chevron.right"
            )
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 17
            )
        )
    }

    // MARK: - Section Header

    private func sectionHeader(
        _ title: String
    ) -> some View {

        Text(title)
            .font(.system(
                size: 10,
                weight: .bold
            ))
            .tracking(1)
            .foregroundStyle(.secondary)
    }
}
