import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Data

    @Query(sort: \TaskItem.dueDate)
    private var tasks: [TaskItem]

    @Query(sort: \Goal.createdAt)
    private var goals: [Goal]

    @Query(sort: \CalendarEvent.startDate)
    private var events: [CalendarEvent]

    // MARK: - User Data

    @AppStorage("firstName")
    private var firstName = ""

    @AppStorage("selectedAvatar")
    private var selectedAvatar = ""

    @AppStorage("journeyStartDate")
    private var journeyStartDate: Double = 0

    // MARK: - State

    @State private var selectedDate = Date()
    @State private var showingGoals = false
    @State private var showingProfile = false

    // MARK: - Constants

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    private let calendar = Calendar.current

    // MARK: - Computed Properties

    private var welcomeName: String {
        firstName.isEmpty ? "User" : firstName
    }

    private var avatarName: String {
        selectedAvatar.isEmpty
            ? "02-smug"
            : selectedAvatar
    }

    private var todayTasks: [TaskItem] {

        tasks
            .filter { task in

                guard let dueDate = task.dueDate else {
                    return false
                }

                return calendar.isDate(
                    dueDate,
                    inSameDayAs: selectedDate
                )
            }
            .sorted {
                priorityRank($0.priority)
                <
                priorityRank($1.priority)
            }
    }

    private var todayEvents: [CalendarEvent] {

        events
            .filter {
                eventOccursOnDate(
                    $0,
                    date: selectedDate
                )
            }
            .sorted {
                $0.startDate < $1.startDate
            }
    }

    private var completedToday: Int {

        todayTasks.filter {
            $0.isComplete
        }.count
    }

    private var taskProgress: Double {

        guard !todayTasks.isEmpty else {
            return 0
        }

        return Double(completedToday)
            / Double(todayTasks.count)
    }

    private var dayNumber: Int {

        guard journeyStartDate > 0 else {
            return 1
        }

        let startDate = Date(
            timeIntervalSince1970:
                journeyStartDate
        )

        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(
                for: startDate
            ),
            to: calendar.startOfDay(
                for: Date()
            )
        ).day ?? 0

        return min(
            max(days + 1, 1),
            84
        )
    }

    private var journeyProgress: Double {
        Double(dayNumber) / 84.0
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 26
                ) {

                    header

                    journeyHeader

                    goalsArea

                    journeyMascot

                    todaySection

                    Spacer(
                        minLength: 30
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .background(
                Color(.systemBackground)
            )
            .navigationBarHidden(true)

            // MARK: Profile

            .sheet(
                isPresented:
                    $showingProfile
            ) {

                NavigationStack {
                    ProfileView()
                }
            }

            // MARK: Goals

            .sheet(
                isPresented:
                    $showingGoals
            ) {

                NavigationStack {
                    GoalsView()
                }
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

                Text("Welcome")
                    .font(
                        .system(
                            size: 15,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )

                Text(welcomeName)
                    .font(
                        .system(
                            size: 32,
                            weight: .bold
                        )
                    )
            }

            Spacer()

            Button {

                showingProfile = true

            } label: {

                Group {

                    if selectedAvatar.isEmpty {

                        Image(
                            systemName:
                                "person.circle.fill"
                        )
                        .resizable()

                    } else {

                        Image(
                            selectedAvatar
                        )
                        .resizable()
                        .scaledToFit()
                    }
                }
                .frame(
                    width: 48,
                    height: 48
                )
                .background(
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    Circle()
                )
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

    // MARK: - Journey Header

    private var journeyHeader: some View {

        VStack(
            alignment: .leading,
            spacing: 9
        ) {

            HStack(
                alignment: .bottom
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("YOUR 84 DAYS")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(1)
                        .foregroundStyle(
                            .secondary
                        )

                    Text(
                        "Day \(dayNumber) of 84"
                    )
                    .font(
                        .system(
                            size: 27,
                            weight: .bold
                        )
                    )
                }

                Spacer()

                Text(
                    "\(Int(journeyProgress * 100))%"
                )
                .font(
                    .system(
                        size: 14,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    coral
                )
            }

            GeometryReader { geometry in

                ZStack(
                    alignment: .leading
                ) {

                    Capsule()
                        .fill(
                            Color.secondary
                                .opacity(0.12)
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
            .frame(height: 8)
        }
    }

    // MARK: - Goals

    private var goalsArea: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Text("GOALS")
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .tracking(1)
                    .foregroundStyle(
                        .secondary
                    )

                Spacer()

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    .secondary
                )
            }

            Button {

                showingGoals = true

            } label: {

                if goals.isEmpty {

                    emptyGoalsCard

                } else {

                    goalsCard
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyGoalsCard: some View {

        HStack(
            spacing: 14
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(
                    coral.opacity(0.10)
                )

                Image(
                    systemName:
                        "target"
                )
                .font(
                    .system(
                        size: 22,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    coral
                )
            }
            .frame(
                width: 48,
                height: 48
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    "Set your goals"
                )
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )

                Text(
                    "Tap to create your long-term goals."
                )
                .font(
                    .system(size: 12)
                )
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()

            Image(
                systemName:
                    "plus"
            )
            .font(
                .system(
                    size: 15,
                    weight: .bold
                )
            )
            .foregroundStyle(
                coral
            )
        }
        .padding(16)
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }

    private var goalsCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            ForEach(
                goals.prefix(3)
            ) { goal in

                HStack(
                    spacing: 12
                ) {

                    ZStack {

                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            coral.opacity(0.10)
                        )

                        Image(
                            systemName:
                                goal.icon
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            coral
                        )
                    }
                    .frame(
                        width: 42,
                        height: 42
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text(
                            goal.name
                        )
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            .primary
                        )

                        if let category =
                            goal.category,
                           !category.isEmpty {

                            Text(category)
                                .font(
                                    .system(
                                        size: 11
                                    )
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }

                    Spacer()

                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .font(
                        .caption
                    )
                    .foregroundStyle(
                        .tertiary
                    )
                }

                if goal.id !=
                    goals.prefix(3).last?.id {

                    Divider()
                }
            }
        }
        .padding(16)
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }

    // MARK: - Mascot

    private var journeyMascot: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "YOUR JOURNEY STARTS HERE"
            )
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .tracking(1)
            .foregroundStyle(
                .secondary
            )

            HStack(
                alignment: .center,
                spacing: 12
            ) {

                // MASCOT ON LEFT

                Image("02-smug")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 105,
                        height: 125
                    )

                // COMMENT ON RIGHT

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(
                        mascotComment
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        .primary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }
                .padding(
                    .horizontal,
                    16
                )
                .padding(
                    .vertical,
                    14
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18
                    )
                )
            }
        }
    }

    // MARK: - Today + Progress

    private var todaySection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            // HEADER

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text("TODAY")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(1)
                        .foregroundStyle(
                            .secondary
                        )

                    Text(
                        selectedDate.formatted(
                            .dateTime
                                .weekday(.wide)
                                .month(.wide)
                                .day()
                        )
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                }

                Spacer()

                Button {

                    selectedDate = Date()

                } label: {

                    Text("Today")
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            coral
                        )
                }
            }

            // TODAY'S PROGRESS

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                HStack {

                    Text(
                        "\(completedToday) of \(todayTasks.count) tasks completed"
                    )
                    .font(
                        .system(size: 12)
                    )
                    .foregroundStyle(
                        .secondary
                    )

                    Spacer()

                    Text(
                        "\(Int(taskProgress * 100))%"
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        coral
                    )
                }

                GeometryReader { geometry in

                    ZStack(
                        alignment: .leading
                    ) {

                        Capsule()
                            .fill(
                                Color.secondary
                                    .opacity(0.12)
                            )

                        Capsule()
                            .fill(coral)
                            .frame(
                                width:
                                    geometry.size.width
                                    * taskProgress
                            )
                    }
                }
                .frame(height: 7)
            }

            // TASKS

            if todayTasks.isEmpty {

                emptyTodayCard

            } else {

                VStack(
                    spacing: 9
                ) {

                    ForEach(
                        todayTasks.prefix(4)
                    ) { task in

                        taskPreview(task)
                    }
                }
            }

            // EVENTS

            if !todayEvents.isEmpty {

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Text("UPCOMING")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(1)
                        .foregroundStyle(
                            .secondary
                        )

                    ForEach(
                        todayEvents.prefix(3)
                    ) { event in

                        NavigationLink {

                            EventEditorView(
                                event: event
                            )

                        } label: {

                            eventPreview(
                                event
                            )
                        }
                        .buttonStyle(
                            .plain
                        )
                    }
                }
            }

            // SMALL STATS

            HStack(
                spacing: 12
            ) {

                miniStat(
                    value:
                        "\(completedToday)",
                    label:
                        "Tasks done",
                    icon:
                        "checkmark.circle.fill"
                )

                miniStat(
                    value:
                        "\(todayEvents.count)",
                    label:
                        "Events",
                    icon:
                        "calendar"
                )
            }
        }
    }

    // MARK: - Empty Today

    private var emptyTodayCard: some View {

        HStack(
            spacing: 14
        ) {

            Image(
                systemName:
                    "checkmark.circle"
            )
            .font(
                .title2
            )
            .foregroundStyle(
                .secondary
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    "Nothing planned yet"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )

                Text(
                    "Your tasks will appear here."
                )
                .font(
                    .system(size: 12)
                )
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()
        }
        .padding(16)
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // MARK: - Mini Stat

    private func miniStat(
        value: String,
        label: String,
        icon: String
    ) -> some View {

        HStack(
            spacing: 10
        ) {

            Image(
                systemName: icon
            )
            .foregroundStyle(
                coral
            )

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text(value)
                    .font(
                        .system(
                            size: 19,
                            weight: .bold
                        )
                    )

                Text(label)
                    .font(
                        .system(size: 10)
                    )
                    .foregroundStyle(
                        .secondary
                    )
            }

            Spacer()
        }
        .padding(13)
        .frame(
            maxWidth: .infinity
        )
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Task Preview

    private func taskPreview(
        _ task: TaskItem
    ) -> some View {

        HStack(
            spacing: 12
        ) {

            Image(
                systemName:
                    task.isComplete
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .font(
                .system(size: 23)
            )
            .foregroundStyle(
                task.isComplete
                ? coral
                : .secondary
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    task.name.isEmpty
                    ? "Untitled task"
                    : task.name
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .strikethrough(
                    task.isComplete
                )

                if let dueDate =
                    task.dueDate {

                    Text(
                        dueDate.formatted(
                            .dateTime
                                .hour()
                                .minute()
                        )
                    )
                    .font(
                        .system(size: 11)
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }

            Spacer()

            priorityBadge(
                task.priority
            )
        }
        .padding(14)
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 17
            )
        )
    }

    // MARK: - Event Preview

    private func eventPreview(
        _ event: CalendarEvent
    ) -> some View {

        HStack(
            spacing: 12
        ) {

            Image(
                systemName:
                    "calendar"
            )
            .foregroundStyle(
                coral
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    event.title
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )

                Text(
                    event.isAllDay
                    ? "All day"
                    : event.startDate.formatted(
                        .dateTime
                            .hour()
                            .minute()
                    )
                )
                .font(
                    .system(size: 11)
                )
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()

            Image(
                systemName:
                    "chevron.right"
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .tertiary
            )
        }
        .padding(14)
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 17
            )
        )
    }

    // MARK: - Priority

    private func priorityBadge(
        _ priority: TaskPriority
    ) -> some View {

        Text(
            priority.rawValue
                .capitalized
        )
        .font(
            .system(
                size: 9,
                weight: .bold
            )
        )
        .foregroundStyle(
            priorityColor(priority)
        )
        .padding(
            .horizontal,
            8
        )
        .padding(
            .vertical,
            5
        )
        .background(
            priorityColor(priority)
                .opacity(0.12),
            in: Capsule()
        )
    }

    private func priorityRank(
        _ priority: TaskPriority
    ) -> Int {

        switch priority {

        case .high:
            return 0

        case .medium:
            return 1

        case .low:
            return 2
        }
    }

    private func priorityColor(
        _ priority: TaskPriority
    ) -> Color {

        switch priority {

        case .high:
            return .red

        case .medium:
            return .orange

        case .low:
            return .green
        }
    }

    // MARK: - Mascot Comment

    private var mascotComment: String {

        if todayTasks.isEmpty {

            return "Nothing on the list yet. Bold strategy."

        }

        if completedToday ==
            todayTasks.count {

            return "Well, look at you. Everything's actually done."

        }

        if completedToday > 0 {

            return "You're making progress. Try not to get distracted now."

        }

        return "You've got things to do. Unfortunately, I cannot do them for you."
    }

    // MARK: - Event Logic

    private func eventOccursOnDate(
        _ event: CalendarEvent,
        date: Date
    ) -> Bool {

        if event.repeatRule != "Never" {

            return event.occurs(
                on: date,
                calendar: calendar
            )
        }

        let dayStart =
            calendar.startOfDay(
                for: date
            )

        guard let dayEnd =
            calendar.date(
                byAdding: .day,
                value: 1,
                to: dayStart
            )
        else {
            return false
        }

        return event.startDate < dayEnd &&
               event.endDate > dayStart
    }
}
