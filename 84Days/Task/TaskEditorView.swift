//
//  TaskEditorView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI
import SwiftData

struct TaskEditorView: View {

    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Data

    @Query(sort: \Goal.name)
    private var goals: [Goal]

    // MARK: - Existing Task

    private let existingTask: TaskItem?

    // MARK: - Form State

    @State private var name: String
    @State private var notes: String
    @State private var priority: TaskPriority
    @State private var category: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var selectedGoalID: UUID?
    @State private var icon: String

    // MARK: - UI State

    @State private var showingIconPicker = false

    // MARK: - Constants

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    private let icons = [
        "checkmark.circle",
        "book",
        "briefcase",
        "figure.run",
        "figure.walk",
        "house",
        "graduationcap",
        "pencil",
        "brain.head.profile",
        "heart",
        "star",
        "target",
        "calendar",
        "clock",
        "person"
    ]

    // MARK: - Initialiser

    init(task: TaskItem? = nil, defaultPriority: TaskPriority? = nil) {
        self.existingTask = task

        _name = State(initialValue: task?.name ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _priority = State(initialValue: task?.priority ?? defaultPriority ?? .medium)
        _category = State(initialValue: task?.category ?? "")
        _dueDate = State(initialValue: task?.dueDate ?? Date())
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _selectedGoalID = State(initialValue: task?.goalID)
        _icon = State(initialValue: task?.icon ?? "checkmark.circle")
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            Form {

                // MARK: Details

                Section("Task") {

                    TextField(
                        "Task name",
                        text: $name
                    )

                    TextField(
                        "Notes",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(
                        3...6
                    )

                    HStack {

                        Text("Icon")

                        Spacer()

                        Button {

                            showingIconPicker = true

                        } label: {

                            Image(systemName: icon)
                                .font(.system(size: 22))
                                .foregroundStyle(coral)
                        }
                    }
                }

                // MARK: Priority

                Section("Priority") {

                    Picker(
                        "Priority",
                        selection: $priority
                    ) {

                        Text("High")
                            .tag(TaskPriority.high)

                        Text("Medium")
                            .tag(TaskPriority.medium)

                        Text("Low")
                            .tag(TaskPriority.low)
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: Category

                Section("Category") {

                    TextField(
                        "e.g. Study, Health, Work",
                        text: $category
                    )
                }

                // MARK: Schedule

                Section("Schedule") {

                    Toggle(
                        "Set due date",
                        isOn: $hasDueDate
                    )

                    if hasDueDate {

                        DatePicker(
                            "Due",
                            selection: $dueDate,
                            displayedComponents: [
                                .date,
                                .hourAndMinute
                            ]
                        )
                    }
                }

                // MARK: Goal

                Section("Goal") {

                    if goals.isEmpty {

                        Text(
                            "Create a goal first to link this task."
                        )
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)

                    } else {

                        Picker(
                            "Linked goal",
                            selection: $selectedGoalID
                        ) {

                            Text("No goal")
                                .tag(UUID?.none)

                            ForEach(goals) { goal in

                                Label(
                                    goal.name,
                                    systemImage: goal.icon
                                )
                                .tag(UUID?.some(goal.id))
                            }
                        }
                    }
                }

                // MARK: Delete

                if existingTask != nil {

                    Section {

                        Button(
                            role: .destructive
                        ) {

                            deleteTask()

                        } label: {

                            HStack {

                                Spacer()

                                Label(
                                    "Delete Task",
                                    systemImage: "trash"
                                )

                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(
                existingTask == nil
                ? "New Task"
                : "Edit Task"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Save") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(
                        name
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
            .sheet(
                isPresented: $showingIconPicker
            ) {

                iconPicker
            }
        }
    }

    // MARK: Icon Picker

    private var iconPicker: some View {

        NavigationStack {

            ScrollView {

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 60))
                    ],
                    spacing: 20
                ) {

                    ForEach(
                        icons,
                        id: \.self
                    ) { iconName in

                        Button {

                            icon = iconName
                            showingIconPicker = false

                        } label: {

                            Image(
                                systemName: iconName
                            )
                            .font(.system(size: 24))
                            .foregroundStyle(
                                icon == iconName
                                ? coral
                                : .primary
                            )
                            .frame(
                                width: 55,
                                height: 55
                            )
                            .background(
                                icon == iconName
                                ? coral.opacity(0.12)
                                : Color(
                                    .secondarySystemBackground
                                ),
                                in: RoundedRectangle(
                                    cornerRadius: 14
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([
            .medium,
            .large
        ])
    }

    // MARK: Save

    private func saveTask() {

        let cleanedName = name
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedNotes = notes
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanedCategory = category
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if let task = existingTask {

            task.name = cleanedName

            task.notes = cleanedNotes.isEmpty
                ? nil
                : cleanedNotes

            task.priority = priority

            task.category = cleanedCategory.isEmpty
                ? nil
                : cleanedCategory

            task.dueDate = hasDueDate
                ? dueDate
                : nil

            task.goalID = selectedGoalID

            task.icon = icon

            task.updatedAt = .now

        } else {

            let task = TaskItem(
                name: cleanedName,
                notes: cleanedNotes.isEmpty
                    ? nil
                    : cleanedNotes,
                priority: priority,
                icon: icon,
                category: cleanedCategory.isEmpty
                    ? nil
                    : cleanedCategory,
                dueDate: hasDueDate
                    ? dueDate
                    : nil,
                goalID: selectedGoalID
            )

            modelContext.insert(task)
        }

        dismiss()
    }

    // MARK: Delete

    private func deleteTask() {

        guard let task = existingTask else {
            return
        }

        modelContext.delete(task)
        dismiss()
    }
}
