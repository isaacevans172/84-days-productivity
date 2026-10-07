import SwiftUI
import SwiftData

struct ProgressView: View {

    @Query(
        sort: \Goal.targetDate,
        order: .forward
    )
    private var goals: [Goal]

    @Query
    private var tasks: [TaskItem]

    @AppStorage("journeyStartDate")
    private var journeyStartDate: Double =
        Date().timeIntervalSince1970

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    // MARK: Journey

    private var startDate: Date {
        Date(
            timeIntervalSince1970: journeyStartDate
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

        let difference =
            calendar.dateComponents(
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
            1,
            max(
                0,
                Double(currentDay) / 84
            )
        )
    }

    private var journeyPercentage: Int {
        Int(journeyProgress * 100)
    }

    // MARK: Goal Progress

    private func tasksForGoal(
        _ goal: Goal
    ) -> [TaskItem] {

        tasks.filter {
            $0.goalID == goal.id
        }
    }

    private func completedTasksForGoal(
        _ goal: Goal
    ) -> Int {

        tasksForGoal(goal)
            .filter(\.isComplete)
            .count
    }

    private func goalProgress(
        _ goal: Goal
    ) -> Double? {

        let linkedTasks = tasksForGoal(goal)

        guard !linkedTasks.isEmpty else {
            return nil
        }

        return Double(
            linkedTasks.filter(\.isComplete).count
        ) / Double(linkedTasks.count)
    }

    private func goalPercentage(
        _ goal: Goal
    ) -> Int? {

        guard let progress = goalProgress(goal) else {
            return nil
        }

        return Int(progress * 100)
    }

    // MARK: Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                header

                journeyCard

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

    // MARK: Header

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 5
        ) {

            Text("YOUR JOURNEY")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            Text("Progress")
                .font(
                    .system(
                        size: 32,
                        weight: .bold
                    )
                )

            Text(
                "See how close you are to your goals."
            )
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
        }
    }

    // MARK: Journey Card

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
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    Text(
                        "Day \(currentDay) of 84"
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 4
                ) {

                    Text(
                        "\(journeyPercentage)%"
                    )
                    .font(
                        .system(
                            size: 25,
                            weight: .bold
                        )
                    )
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
                                geometry.size.width
                                * journeyProgress
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

    // MARK: Goals

    private var goalsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("GOAL PROGRESS")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            if goals.isEmpty {

                emptyGoalsCard

            } else {

                ForEach(goals) { goal in
                    goalProgressCard(goal)
                }
            }
        }
    }

    // MARK: Goal Card

    private func goalProgressCard(
        _ goal: Goal
    ) -> some View {

        let linkedTasks = tasksForGoal(goal)
        let completed = completedTasksForGoal(goal)
        let progress = goalProgress(goal)
        let percentage = goalPercentage(goal)

        return VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack(spacing: 12) {

                Image(systemName: goal.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(coral)
                    .frame(
                        width: 42,
                        height: 42
                    )
                    .background(
                        coral.opacity(0.10),
                        in: RoundedRectangle(
                            cornerRadius: 12
                        )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(goal.name)
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .lineLimit(2)

                    if let category = goal.category,
                       !category.isEmpty {

                        Text(category)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let percentage {

                    Text("\(percentage)%")
                        .font(
                            .system(
                                size: 19,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(coral)
                }
            }

            if let progress {

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
                                    geometry.size.width
                                    * progress
                            )
                    }
                }
                .frame(height: 8)

                HStack {

                    Text(
                        "\(completed) of \(linkedTasks.count) tasks completed"
                    )

                    Spacer()

                    if let targetDate = goal.targetDate {

                        Text(
                            targetDate.formatted(
                                .dateTime
                                    .day()
                                    .month(.abbreviated)
                            )
                        )
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            } else {

                Text("No tasks linked yet")
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.secondary)
            }
        }
        .padding(17)
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

    // MARK: Empty Goals

    private var emptyGoalsCard: some View {

        VStack(
            alignment: .leading,
            spacing: 7
        ) {

            Image(systemName: "target")
                .font(.system(size: 24))
                .foregroundStyle(coral)

            Text("No goals yet")
                .font(
                    .system(
                        size: 16,
                        weight: .bold
                    )
                )

            Text(
                "Create a long-term goal and link tasks to it to start tracking your progress."
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
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 20
            )
        )
    }
}
