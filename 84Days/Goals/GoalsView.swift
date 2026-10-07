//
//  GoalsView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI
import SwiftData

struct GoalsView: View {

    // MARK: - Data

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \Goal.targetDate,
        order: .forward
    )
    private var goals: [Goal]

    // MARK: - State

    @State private var showingAddGoal = false
    @State private var selectedGoal: Goal?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    header

                    focusMessage

                    if goals.isEmpty {
                        emptyState
                    } else {
                        goalsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom) {
                addGoalButton
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            NavigationStack {
                GoalEditorView()
            }
        }
        .sheet(item: $selectedGoal) { goal in
            NavigationStack {
                GoalEditorView(goal: goal)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("YOUR FUTURE")
                    .font(.system(
                        size: 11,
                        weight: .bold
                    ))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text("Goals")
                    .font(.system(
                        size: 32,
                        weight: .bold
                    ))
            }

            Spacer()

            Button {
                showingAddGoal = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(
                        size: 17,
                        weight: .bold
                    ))
                    .foregroundStyle(.white)
                    .frame(
                        width: 40,
                        height: 40
                    )
                    .background(
                        coral,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Focus Message

    private var focusMessage: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack(spacing: 10) {

                Image(systemName: "target")
                    .font(.system(
                        size: 20,
                        weight: .semibold
                    ))
                    .foregroundStyle(coral)

                Text("Think beyond the 84 days")
                    .font(.system(
                        size: 16,
                        weight: .bold
                    ))
            }

            Text(
                "Goals are the bigger things you want to keep working towards after your 84-day journey."
            )
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            coral.opacity(0.08),
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // MARK: - Goals Section

    private var goalsSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("YOUR GOALS")
                .font(.system(
                    size: 11,
                    weight: .bold
                ))
                .tracking(1)
                .foregroundStyle(.secondary)

            ForEach(goals) { goal in
                goalCard(goal)
            }
        }
    }

    // MARK: - Goal Card

    private func goalCard(
        _ goal: Goal
    ) -> some View {

        Button {
            selectedGoal = goal
        } label: {

            VStack(
                alignment: .leading,
                spacing: 14
            ) {

                HStack(
                    alignment: .top,
                    spacing: 12
                ) {

                    Image(systemName: goal.icon)
                        .font(.system(
                            size: 20,
                            weight: .semibold
                        ))
                        .foregroundStyle(coral)
                        .frame(
                            width: 44,
                            height: 44
                        )
                        .background(
                            coral.opacity(0.10),
                            in: RoundedRectangle(
                                cornerRadius: 13
                            )
                        )

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(
                            goal.name.isEmpty
                            ? "Untitled goal"
                            : goal.name
                        )
                        .font(.system(
                            size: 17,
                            weight: .bold
                        ))
                        .foregroundStyle(.primary)

                        if let category = goal.category,
                           !category.isEmpty {

                            Text(category)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(
                            size: 12,
                            weight: .semibold
                        ))
                        .foregroundStyle(.tertiary)
                }

                if let notes = goal.notes,
                   !notes.isEmpty {

                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }

                HStack {

                    if let targetDate = goal.targetDate {

                        Label(
                            targetDate.formatted(
                                .dateTime
                                    .day()
                                    .month(.abbreviated)
                                    .year()
                            ),
                            systemImage: "calendar"
                        )
                    } else {

                        Label(
                            "No target date",
                            systemImage: "calendar"
                        )
                    }

                    Spacer()

                    let linkedTaskCount = taskCount(
                        for: goal
                    )

                    Label(
                        "\(linkedTaskCount) \(linkedTaskCount == 1 ? "task" : "tasks")",
                        systemImage: "checkmark.circle"
                    )
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            .padding(17)
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(
                    cornerRadius: 20
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(
            spacing: 16
        ) {

            Image(systemName: "target")
                .font(.system(
                    size: 38,
                    weight: .medium
                ))
                .foregroundStyle(coral)

            VStack(spacing: 6) {

                Text("No goals yet")
                    .font(.system(
                        size: 19,
                        weight: .bold
                    ))

                Text(
                    "Add something meaningful you want to work towards beyond your 84 days."
                )
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Button {
                showingAddGoal = true
            } label: {
                Text("Create Your First Goal")
                    .font(.system(
                        size: 14,
                        weight: .bold
                    ))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        coral,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 45)
    }

    // MARK: - Add Goal Button

    private var addGoalButton: some View {
        Button {
            showingAddGoal = true
        } label: {

            HStack {

                Image(systemName: "plus")

                Text("Add Goal")
                    .fontWeight(.bold)
            }
            .font(.system(size: 17))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                coral,
                in: RoundedRectangle(
                    cornerRadius: 18
                )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .buttonStyle(.plain)
        .background(
            Color(.systemBackground)
                .opacity(0.96)
        )
    }

    // MARK: - Helpers

    private func taskCount(
        for goal: Goal
    ) -> Int {

        return tasksForGoal(goal).count
    }

    private func tasksForGoal(
        _ goal: Goal
    ) -> [TaskItem] {

        let descriptor = FetchDescriptor<TaskItem>()

        guard let allTasks = try? modelContext.fetch(descriptor) else {
            return []
        }

        return allTasks.filter {
            $0.goalID == goal.id
        }
    }

    // MARK: - Styling

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )
}
