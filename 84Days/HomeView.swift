import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Data

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

    @Query
    private var profiles: [LocalUserProfile]

    // MARK: - State

    @State private var showingProfile = false
    @State private var showingGoals = false
    @State private var showingMascotChat = false

    @State private var mascotState =
        MascotEngine.state(
            for: .openedApp,
            context: MascotContext(
                isFirstDay: true
            )
        )

    // MARK: - Storage

    @AppStorage("journeyStartDate")
    private var journeyStartDate:
        Double = Date().timeIntervalSince1970

    // MARK: - Styling

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    // MARK: - Journey

    private var journeyDay: Int {

        let calendar = Calendar.current

        let start = calendar.startOfDay(
            for: Date(
                timeIntervalSince1970:
                    journeyStartDate
            )
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

    private var journeyProgress: Double {

        Double(journeyDay) / 84.0
    }

    private var currentWeek: Int {

        min(
            12,
            max(
                1,
                Int(
                    ceil(
                        Double(journeyDay) / 7.0
                    )
                )
            )
        )
    }

    // MARK: - Today

    private var today: Date {

        Calendar.current.startOfDay(
            for: Date()
        )
    }

    private var todayTasks: [TaskItem] {

        tasks.filter { task in

            guard let dueDate = task.dueDate
            else {
                return false
            }

            return Calendar.current.isDate(
                dueDate,
                inSameDayAs: today
            )
        }
    }

    private var todayEvents: [CalendarEvent] {

        events.filter {

            $0.occurs(
                on: today,
                calendar: .current
            )
        }
    }

    private var completedToday: Int {

        todayTasks.filter {
            $0.isComplete
        }.count
    }

    // MARK: - Profile

    private var profile: LocalUserProfile? {

        profiles.first
    }

    private var avatarName: String {

        profile?.avatar ?? "01-deadpan"
    }

    private var displayName: String {

        guard let profile else {
            return "Welcome back"
        }

        let name =
            "\(profile.firstName) \(profile.lastName)"
                .trimmingCharacters(
                    in: .whitespaces
                )

        return name.isEmpty
            ? "Welcome back"
            : name
    }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {

                header

                journeyCard

                mascotSection

                todaySection

                goalsSection

                Spacer(minLength: 80)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(
            Color(.systemBackground)
        )
        .onAppear {

            updateMascot()
        }
        .sheet(
            isPresented: $showingProfile
        ) {

            NavigationStack {
                ProfileView()
            }
        }
        .sheet(
            isPresented: $showingGoals
        ) {

            NavigationStack {
                GoalsView()
            }
        }
        .sheet(
            isPresented: $showingMascotChat
        ) {

            NavigationStack {
                MascotChatView()
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

                Text(greeting)
                    .font(.system(
                        size: 13,
                        weight: .medium
                    ))
                    .foregroundStyle(.secondary)

                Text(displayName)
                    .font(.system(
                        size: 30,
                        weight: .bold
                    ))
            }

            Spacer()

            Button {

                showingProfile = true

            } label: {

                Image(avatarName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 46,
                        height: 46
                    )
                    .background(
                        Color(.secondarySystemBackground),
                        in: Circle()
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                coral.opacity(0.25),
                                lineWidth: 2
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var greeting: String {

        let hour =
            Calendar.current.component(
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
            return "Welcome back"
        }
    }

    // MARK: - Journey

    private var journeyCard: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("YOUR JOURNEY")
                .font(.system(
                    size: 10,
                    weight: .bold
                ))
                .tracking(1)
                .foregroundStyle(.secondary)

            Text("Your journey starts here")
                .font(.system(
                    size: 24,
                    weight: .bold
                ))

            Text(
                "84 days to build consistency, make progress and actually get somewhere."
            )
            .font(.system(size: 13))
            .foregroundStyle(.secondary)

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
            .frame(height: 7)

            HStack {

                Text(
                    "Day \(journeyDay) of 84"
                )
                .font(.system(
                    size: 11,
                    weight: .semibold
                ))

                Spacer()

                Text(
                    "Week \(currentWeek) of 12"
                )
                .font(.system(
                    size: 11,
                    weight: .semibold
                ))
                .foregroundStyle(.secondary)
            }
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

    // MARK: - Mascot

    private var mascotSection: some View {

        VStack(spacing: 8) {

            MascotView(
                state: mascotState
            )
            .frame(
                maxWidth: .infinity
            )

            Button {

                showingMascotChat = true

            } label: {

                HStack {

                    Text(
                        mascotState.message
                    )
                    .font(.system(
                        size: 14,
                        weight: .medium
                    ))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                    Spacer()

                    Image(
                        systemName:
                            "bubble.left.fill"
                    )
                    .foregroundStyle(coral)
                }
                .padding(14)
                .background(
                    Color(.secondarySystemBackground),
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Today

    private var todaySection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Text("TODAY")
                    .font(.system(
                        size: 10,
                        weight: .bold
                    ))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(
                    "\(completedToday)/\(todayTasks.count)"
                )
                .font(.system(
                    size: 11,
                    weight: .semibold
                ))
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {

                overviewCard(
                    value:
                        "\(todayTasks.count)",
                    title: "Tasks",
                    icon:
                        "checkmark.circle"
                )

                overviewCard(
                    value:
                        "\(todayEvents.count)",
                    title: "Events",
                    icon: "calendar"
                )
            }

            if !todayTasks.isEmpty {

                ForEach(
                    todayTasks.prefix(3)
                ) { task in

                    taskRow(task)
                }
            }

            if !todayEvents.isEmpty {

                ForEach(
                    todayEvents.prefix(3)
                ) { event in

                    eventRow(event)
                }
            }

            if todayTasks.isEmpty &&
                todayEvents.isEmpty {

                Text(
                    "Nothing scheduled yet. You've got a clean slate."
                )
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
            }
        }
    }

    private func overviewCard(
        value: String,
        title: String,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Image(systemName: icon)
                .foregroundStyle(coral)

            Text(value)
                .font(.system(
                    size: 23,
                    weight: .bold
                ))

            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(15)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 17
            )
        )
    }

    private func taskRow(
        _ task: TaskItem
    ) -> some View {

        HStack(spacing: 11) {

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

            Text(
                task.name.isEmpty
                ? "Untitled task"
                : task.name
            )
            .font(.system(
                size: 14,
                weight: .medium
            ))
            .strikethrough(
                task.isComplete
            )

            Spacer()
        }
        .padding(13)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 15
            )
        )
    }

    private func eventRow(
        _ event: CalendarEvent
    ) -> some View {

        HStack(spacing: 11) {

            Image(systemName: "calendar")
                .foregroundStyle(coral)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(event.title)
                    .font(.system(
                        size: 14,
                        weight: .medium
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
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(13)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 15
            )
        )
    }

    // MARK: - Goals

    private var goalsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 11
        ) {

            HStack {

                Text("LONG-TERM GOALS")
                    .font(.system(
                        size: 10,
                        weight: .bold
                    ))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Manage") {

                    showingGoals = true
                }
                .font(.system(
                    size: 12,
                    weight: .semibold
                ))
                .foregroundStyle(coral)
            }

            if goals.isEmpty {

                Button {

                    showingGoals = true

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "plus.circle.fill"
                        )
                        .foregroundStyle(coral)

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                "Add your first goal"
                            )
                            .font(.system(
                                size: 14,
                                weight: .semibold
                            ))
                            .foregroundStyle(.primary)

                            Text(
                                "Something bigger to work towards after the 84 days."
                            )
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(
                            systemName:
                                "chevron.right"
                        )
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    }
                    .padding(15)
                    .background(
                        Color(.secondarySystemBackground),
                        in: RoundedRectangle(
                            cornerRadius: 17
                        )
                    )
                }
                .buttonStyle(.plain)

            } else {

                ForEach(
                    goals.prefix(2)
                ) { goal in

                    HStack(spacing: 12) {

                        Image(
                            systemName:
                                goal.icon
                        )
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
                            spacing: 3
                        ) {

                            Text(goal.name)
                                .font(.system(
                                    size: 14,
                                    weight: .semibold
                                ))

                            if let category =
                                goal.category {

                                Text(category)
                                    .font(.system(
                                        size: 10
                                    ))
                                    .foregroundStyle(
                                        .secondary
                                    )
                            }
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(
                        Color(
                            .secondarySystemBackground
                        ),
                        in: RoundedRectangle(
                            cornerRadius: 17
                        )
                    )
                }
            }
        }
    }

    // MARK: - Mascot State

    private func updateMascot() {

        let context = MascotContext(
            currentDay: journeyDay,
            currentStreak:
                profile?.currentStreak ?? 0,
            longestStreak:
                profile?.longestStreak ?? 0,
            completedDays: 0,
            missedDays: 0,
            progressPercentage:
                journeyProgress * 100,
            isFirstDay:
                journeyDay == 1,
            returnedAfterAbsence: false
        )

        mascotState =
            MascotEngine.state(
                for: .openedApp,
                context: context
            )
    }
}
