import SwiftUI
import SwiftData

struct TasksView: View {

    // MARK: - Data

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \TaskItem.dueDate)
    private var tasks: [TaskItem]

    // MARK: - State

    @State private var filter: TaskFilter = .all
    @State private var showingAddTask = false
    @State private var addingPriority: TaskPriority?

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {

                header
                suggestedTasks
                filterBar
                taskSections
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
        .background(
            Color(.systemBackground)
        )

        // Add Task sits above the tab bar
        .safeAreaInset(
            edge: .bottom,
            spacing: 0
        ) {

            addTaskButton
                .background(
                    .ultraThinMaterial
                )
        }

        // MARK: Add Task Sheet

        .sheet(
            isPresented: $showingAddTask
        ) {

            NavigationStack {
                TaskEditorView()
            }
        }

        // MARK: Priority Add Sheet

        .sheet(
            isPresented: Binding(
                get: {
                    addingPriority != nil
                },
                set: { newValue in
                    if !newValue {
                        addingPriority = nil
                    }
                }
            )
        ) {

            NavigationStack {
                TaskEditorView(
                    defaultPriority:
                        addingPriority ?? .medium
                )
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

                Text("YOUR TASKS")
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text("Tasks")
                    .font(
                        .system(
                            size: 32,
                            weight: .bold
                        )
                    )
            }

            Spacer()

            Menu {

                Button {
                    filter = .all
                } label: {
                    Label(
                        "All Tasks",
                        systemImage:
                            filter == .all
                            ? "checkmark"
                            : "list.bullet"
                    )
                }

                Button {
                    filter = .incomplete
                } label: {
                    Label(
                        "Incomplete",
                        systemImage:
                            filter == .incomplete
                            ? "checkmark"
                            : "circle"
                    )
                }

                Button {
                    filter = .completed
                } label: {
                    Label(
                        "Completed",
                        systemImage:
                            filter == .completed
                            ? "checkmark"
                            : "checkmark.circle"
                    )
                }

                Divider()

                Button(
                    role: .destructive
                ) {
                    deleteCompleted()
                } label: {
                    Label(
                        "Delete Completed",
                        systemImage: "trash"
                    )
                }

            } label: {

                Image(
                    systemName:
                        "ellipsis.circle"
                )
                .font(.system(size: 25))
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Suggested Tasks

    private var suggestedTasks: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("SUGGESTED STEPS")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(.secondary)

            Text(
                "Small actions to help you make progress."
            )
            .font(.system(size: 13))
            .foregroundStyle(.secondary)

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 10) {

                    suggestedButton(
                        title: "Review today's goals",
                        priority: .high
                    )

                    suggestedButton(
                        title: "Study for 20 minutes",
                        priority: .medium
                    )

                    suggestedButton(
                        title: "Complete an assignment",
                        priority: .high
                    )

                    suggestedButton(
                        title: "Organise your workspace",
                        priority: .low
                    )

                    suggestedButton(
                        title: "Exercise for 30 minutes",
                        priority: .medium
                    )

                    suggestedButton(
                        title: "Plan tomorrow",
                        priority: .low
                    )
                }
            }
        }
    }

    private func suggestedButton(
        title: String,
        priority: TaskPriority
    ) -> some View {

        Button {

            let task = TaskItem(
                name: title,
                priority: priority,
                dueDate: Date()
            )

            modelContext.insert(task)

        } label: {

            HStack(spacing: 7) {

                Image(
                    systemName:
                        "plus.circle.fill"
                )
                .font(.system(size: 13))

                Text(title)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .lineLimit(1)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                Color(.secondarySystemBackground),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filter

    private var filterBar: some View {

        HStack(spacing: 8) {

            filterButton(
                title: "All",
                filter: .all
            )

            filterButton(
                title: "Open",
                filter: .incomplete
            )

            filterButton(
                title: "Done",
                filter: .completed
            )

            Spacer()
        }
    }

    private func filterButton(
        title: String,
        filter: TaskFilter
    ) -> some View {

        Button {
            self.filter = filter
        } label: {

            Text(title)
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    self.filter == filter
                    ? .white
                    : .primary
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    self.filter == filter
                    ? coral
                    : Color(
                        .secondarySystemBackground
                    ),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Task Sections

    private var taskSections: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            prioritySection(
                title: "High",
                priority: .high
            )

            prioritySection(
                title: "Medium",
                priority: .medium
            )

            prioritySection(
                title: "Low",
                priority: .low
            )
        }
    }

    private func prioritySection(
        title: String,
        priority: TaskPriority
    ) -> some View {

        let sectionTasks = filteredTasks(
            for: priority
        )

        return VStack(
            alignment: .leading,
            spacing: 9
        ) {

            HStack {

                Text(title)
                    .font(
                        .system(
                            size: 17,
                            weight: .bold
                        )
                    )

                Text(
                    "\(sectionTasks.count)"
                )
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Color(
                        .tertiarySystemBackground
                    ),
                    in: Capsule()
                )

                Spacer()

                Button {

                    addingPriority = priority

                } label: {

                    Image(
                        systemName: "plus"
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .frame(
                        width: 32,
                        height: 32
                    )
                    .background(
                        Color(
                            .secondarySystemBackground
                        ),
                        in: Circle()
                    )
                }
                .buttonStyle(.plain)
            }

            if sectionTasks.isEmpty {

                Text(
                    filter == .completed
                    ? "No completed tasks here."
                    : "No \(title.lowercased()) priority tasks."
                )
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)

            } else {

                ForEach(sectionTasks) { task in
                    taskRow(task)
                }
            }
        }
    }

    // MARK: - Task Row

    private func taskRow(
        _ task: TaskItem
    ) -> some View {

        HStack(spacing: 12) {

            Button {

                toggleTask(task)

            } label: {

                Image(
                    systemName:
                        task.isComplete
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 24))
                .foregroundStyle(
                    task.isComplete
                    ? coral
                    : .secondary
                )
            }
            .buttonStyle(.plain)

            NavigationLink {

                TaskEditorView(
                    task: task
                )

            } label: {

                VStack(
                    alignment: .leading,
                    spacing: 5
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

                    HStack(spacing: 8) {

                        if let category = task.category,
                           !category.isEmpty {

                            Label(
                                category,
                                systemImage: "tag"
                            )
                        }

                        if let dueDate = task.dueDate {

                            Label(
                                dueDate.formatted(
                                    .dateTime
                                        .hour()
                                        .minute()
                                ),
                                systemImage: "clock"
                            )
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .buttonStyle(.plain)

            priorityBadge(
                task.priority
            )
        }
        .padding(15)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // MARK: - Add Task Button

    private var addTaskButton: some View {

        Button {

            showingAddTask = true

        } label: {

            HStack {

                Image(
                    systemName: "plus"
                )

                Text("Add Task")
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
            .padding(.bottom, 10)
        }
        .buttonStyle(.plain)
        .background(
            Color(.systemBackground)
                .opacity(0.96)
        )
    }

    // MARK: - Filtering

    private func filteredTasks(
        for priority: TaskPriority
    ) -> [TaskItem] {

        tasks
            .filter {
                $0.priority == priority
            }
            .filter {

                switch filter {

                case .all:
                    return true

                case .completed:
                    return $0.isComplete

                case .incomplete:
                    return !$0.isComplete
                }
            }
            .sorted {

                switch (
                    $0.dueDate,
                    $1.dueDate
                ) {

                case let (a?, b?):
                    return a < b

                case (_, nil):
                    return true

                case (nil, _):
                    return false

                default:
                    return $0.createdAt < $1.createdAt
                }
            }
    }

    // MARK: - Actions

    private func toggleTask(
        _ task: TaskItem
    ) {

        task.isComplete.toggle()

        task.completedAt =
            task.isComplete
            ? .now
            : nil

        task.updatedAt = .now
    }

    private func deleteCompleted() {

        for task in tasks
        where task.isComplete {

            modelContext.delete(task)
        }
    }

    // MARK: - Styling

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    private func priorityBadge(
        _ priority: TaskPriority
    ) -> some View {

        Text(
            priority.rawValue.capitalized
        )
        .font(
            .system(
                size: 10,
                weight: .bold
            )
        )
        .foregroundStyle(
            priorityColor(priority)
        )
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            priorityColor(priority)
                .opacity(0.13),
            in: Capsule()
        )
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
}

// MARK: - Filter

private enum TaskFilter {
    case all
    case completed
    case incomplete
}
