//
//  GoalEditorView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI
import SwiftData

struct GoalEditorView: View {

    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Data

    @Query(
        sort: \TaskItem.createdAt,
        order: .forward
    )
    private var tasks: [TaskItem]

    // MARK: - Existing Goal

    private let existingGoal: Goal?

    // MARK: - State

    @State private var name = ""
    @State private var notes = ""
    @State private var category = ""
    @State private var targetDate = Date()
    @State private var hasTargetDate = false
    @State private var icon = "target"

    @State private var showingIconPicker = false
    @State private var showingDeleteConfirmation = false

    // MARK: - Icons

    private let icons = [
        "target",
        "graduationcap.fill",
        "briefcase.fill",
        "book.fill",
        "heart.fill",
        "figure.run",
        "dumbbell.fill",
        "brain.head.profile",
        "globe",
        "house.fill",
        "dollarsign.circle.fill",
        "star.fill",
        "flag.fill",
        "lightbulb.fill",
        "person.fill"
    ]

    // MARK: - Init

    init(
        goal: Goal? = nil
    ) {
        self.existingGoal = goal

        _name = State(
            initialValue: goal?.name ?? ""
        )

        _notes = State(
            initialValue: goal?.notes ?? ""
        )

        _category = State(
            initialValue: goal?.category ?? ""
        )

        _targetDate = State(
            initialValue: goal?.targetDate ?? Date()
        )

        _hasTargetDate = State(
            initialValue: goal?.targetDate != nil
        )

        _icon = State(
            initialValue: goal?.icon ?? "target"
        )
    }

    // MARK: - Body

    var body: some View {
        Form {

            // MARK: Goal

            Section("Goal") {

                HStack(spacing: 12) {

                    Button {
                        showingIconPicker = true
                    } label: {

                        Image(systemName: icon)
                            .font(.system(
                                size: 21,
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
                                    cornerRadius: 12
                                )
                            )
                    }
                    .buttonStyle(.plain)

                    TextField(
                        "What do you want to achieve?",
                        text: $name
                    )
                }

                TextField(
                    "Notes",
                    text: $notes,
                    axis: .vertical
                )
                .lineLimit(3...6)
            }

            // MARK: Category

            Section("Category") {

                TextField(
                    "e.g. Education, Career, Health",
                    text: $category
                )
            }

            // MARK: Target Date

            Section("Target Date") {

                Toggle(
                    "Set a target date",
                    isOn: $hasTargetDate
                )

                if hasTargetDate {

                    DatePicker(
                        "Target",
                        selection: $targetDate,
                        displayedComponents: .date
                    )
                }
            }

            // MARK: Linked Tasks

            if let goal = existingGoal {

                Section("Linked Tasks") {

                    let linkedTasks = tasks.filter {
                        $0.goalID == goal.id
                    }

                    if linkedTasks.isEmpty {

                        Text("No tasks linked to this goal yet.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(linkedTasks) { task in

                            HStack {

                                Image(
                                    systemName: task.isComplete
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
                                .lineLimit(1)

                                Spacer()
                            }
                        }
                    }
                }
            }

            // MARK: Delete

            if existingGoal != nil {

                Section {

                    Button(
                        "Delete Goal",
                        role: .destructive
                    ) {
                        showingDeleteConfirmation = true
                    }
                }
            }
        }
        .navigationTitle(
            existingGoal == nil
            ? "New Goal"
            : "Edit Goal"
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
                    saveGoal()
                }
                .fontWeight(.semibold)
                .disabled(
                    name.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            NavigationStack {
                iconPicker
            }
        }
        .confirmationDialog(
            "Delete this goal?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {

            Button(
                "Delete Goal",
                role: .destructive
            ) {
                deleteGoal()
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Icon Picker

    private var iconPicker: some View {
        ScrollView {

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 65))
                ],
                spacing: 18
            ) {

                ForEach(icons, id: \.self) { iconName in

                    Button {
                        icon = iconName
                        showingIconPicker = false
                    } label: {

                        Image(systemName: iconName)
                            .font(.system(size: 23))
                            .foregroundStyle(
                                icon == iconName
                                ? .white
                                : coral
                            )
                            .frame(
                                width: 55,
                                height: 55
                            )
                            .background(
                                icon == iconName
                                ? coral
                                : coral.opacity(0.10),
                                in: RoundedRectangle(
                                    cornerRadius: 15
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(25)
        }
        .navigationTitle("Choose Icon")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Save

    private func saveGoal() {

        let cleanedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedName.isEmpty else {
            return
        }

        let cleanedNotes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanedCategory = category.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if let goal = existingGoal {

            goal.name = cleanedName

            goal.notes = cleanedNotes.isEmpty
                ? nil
                : cleanedNotes

            goal.category = cleanedCategory.isEmpty
                ? nil
                : cleanedCategory

            goal.icon = icon

            goal.targetDate = hasTargetDate
                ? targetDate
                : nil

            goal.updatedAt = .now

        } else {

            let goal = Goal(
                name: cleanedName,
                notes: cleanedNotes.isEmpty
                    ? nil
                    : cleanedNotes,
                icon: icon,
                category: cleanedCategory.isEmpty
                    ? nil
                    : cleanedCategory,
                targetDate: hasTargetDate
                    ? targetDate
                    : nil
            )

            modelContext.insert(goal)
        }

        dismiss()
    }

    // MARK: - Delete

    private func deleteGoal() {

        guard let goal = existingGoal else {
            return
        }

        // Remove the relationship from linked tasks
        // before deleting the goal.

        for task in tasks
        where task.goalID == goal.id {

            task.goalID = nil
            task.updatedAt = .now
        }

        modelContext.delete(goal)

        dismiss()
    }

    // MARK: - Styling

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )
}