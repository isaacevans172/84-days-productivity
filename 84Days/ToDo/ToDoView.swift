//
//  ToDoView.swift
//  84Days
//
//  Created by yuvan harith on 5/10/2026.
//
import SwiftUI

// MARK: - TASK MODEL

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String = ""
    var category: String = ""
    var duration: String = ""
    var priority: Priority = .medium
    var completed: Bool = false
    var taskTime: Date = Date()
}


// MARK: - PRIORITY

enum Priority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}


// MARK: - TASK FILTER

enum TaskFilter {
    case all
    case completed
    case incomplete
}


// MARK: - MAIN VIEW

struct TaskPriorityGroupsView: View {

    @State private var tasks: [TaskItem] = []
    @State private var taskFilter: TaskFilter = .all


    // MARK: - SUGGESTED TASKS

    let suggestedTasks: [(title: String, priority: Priority)] = [
        ("Review today's goals", .high),
        ("Study for 20 minutes", .medium),
        ("Complete an assignment", .high),
        ("Organise your workspace", .low),
        ("Exercise for 30 minutes", .medium),
        ("Plan tomorrow", .low)
    ]


    var body: some View {

        VStack(spacing: 0) {


            // MARK: - TOP BAR

            HStack {

                // 84 LOGO

                Image("84Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)


                // TASK TITLE

                Text("Tasks")
                    .font(.system(size: 28))
                    .fontWeight(.bold)


                Spacer()


                // MENU

                Menu {

                    Button {
                        taskFilter = .all
                    } label: {
                        Label(
                            "Show All Tasks",
                            systemImage:
                                taskFilter == .all
                                ? "checkmark"
                                : "list.bullet"
                        )
                    }


                    Button {
                        taskFilter = .completed
                    } label: {
                        Label(
                            "Show Completed",
                            systemImage:
                                taskFilter == .completed
                                ? "checkmark"
                                : "checkmark.circle"
                        )
                    }


                    Button {
                        taskFilter = .incomplete
                    } label: {
                        Label(
                            "Show Incomplete",
                            systemImage:
                                taskFilter == .incomplete
                                ? "checkmark"
                                : "circle"
                        )
                    }


                    Divider()


                    Button(role: .destructive) {

                        tasks.removeAll {
                            $0.completed
                        }

                    } label: {

                        Label(
                            "Delete Completed Tasks",
                            systemImage: "trash"
                        )
                    }

                } label: {

                    Image(systemName: "ellipsis")
                        .font(.system(size: 22))
                        .padding(10)
                }
            }

            .padding(.horizontal, 25)
            .padding(.top, 10)
            .padding(.bottom, 5)



            // MARK: - SUGGESTED STEPS

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                Text("Suggested Steps")
                    .font(.system(size: 19))
                    .fontWeight(.semibold)


                Text("Quick tasks to help you get started")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)


                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {

                    HStack(spacing: 10) {

                        ForEach(
                            Array(
                                suggestedTasks.enumerated()
                            ),
                            id: \.offset
                        ) { item in

                            Button {

                                addSuggestedTask(
                                    title: item.element.title,
                                    priority: item.element.priority
                                )

                            } label: {

                                HStack(spacing: 6) {

                                    Image(
                                        systemName:
                                            "plus.circle.fill"
                                    )
                                    .font(
                                        .system(size: 14)
                                    )


                                    Text(
                                        item.element.title
                                    )
                                    .font(
                                        .system(size: 14)
                                    )
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                }

                                .padding(
                                    .horizontal,
                                    13
                                )

                                .padding(
                                    .vertical,
                                    10
                                )

                                .background(
                                    Color("bubblecolor")
                                )

                                .clipShape(
                                    Capsule()
                                )
                            }

                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            .padding(.horizontal, 25)
            .padding(.top, 8)
            .padding(.bottom, 10)



            // MARK: - HIGH

            List {

                DisclosureGroup {

                    ForEach(
                        filteredIndices(
                            for: .high
                        ),
                        id: \.self
                    ) { index in

                        taskRow(
                            index: index
                        )

                        .listRowSeparator(
                            .hidden
                        )
                    }

                } label: {

                    HStack {

                        Text("High")
                            .font(
                                .system(size: 20)
                            )
                            .fontWeight(
                                .semibold
                            )

                            .padding(
                                .horizontal,
                                31
                            )

                            .padding(
                                .vertical,
                                10
                            )

                            .background(
                                Color("high")
                            )

                            .clipShape(
                                Capsule()
                            )


                        Spacer()


                        Button {

                            tasks.append(
                                TaskItem(
                                    priority: .high
                                )
                            )

                        } label: {

                            Image(
                                systemName: "plus"
                            )
                            .font(
                                .system(size: 20)
                            )
                        }

                        .buttonStyle(
                            .plain
                        )
                    }
                }
            }

            .listStyle(.plain)

            .scrollContentBackground(
                .hidden
            )



            // MARK: - MEDIUM

            List {

                DisclosureGroup {

                    ForEach(
                        filteredIndices(
                            for: .medium
                        ),
                        id: \.self
                    ) { index in

                        taskRow(
                            index: index
                        )

                        .listRowSeparator(
                            .hidden
                        )
                    }

                } label: {

                    HStack {

                        Text("Medium")
                            .font(
                                .system(size: 20)
                            )
                            .fontWeight(
                                .semibold
                            )

                            .padding(
                                .horizontal,
                                31
                            )

                            .padding(
                                .vertical,
                                10
                            )

                            .background(
                                Color("medium")
                            )

                            .clipShape(
                                Capsule()
                            )


                        Spacer()


                        Button {

                            tasks.append(
                                TaskItem(
                                    priority: .medium
                                )
                            )

                        } label: {

                            Image(
                                systemName: "plus"
                            )
                            .font(
                                .system(size: 20)
                            )
                        }

                        .buttonStyle(
                            .plain
                        )
                    }
                }
            }

            .listStyle(.plain)

            .scrollContentBackground(
                .hidden
            )



            // MARK: - LOW

            List {

                DisclosureGroup {

                    ForEach(
                        filteredIndices(
                            for: .low
                        ),
                        id: \.self
                    ) { index in

                        taskRow(
                            index: index
                        )

                        .listRowSeparator(
                            .hidden
                        )
                    }

                } label: {

                    HStack {

                        Text("Low")
                            .font(
                                .system(size: 20)
                            )
                            .fontWeight(
                                .semibold
                            )

                            .padding(
                                .horizontal,
                                31
                            )

                            .padding(
                                .vertical,
                                10
                            )

                            .background(
                                Color("low")
                            )

                            .clipShape(
                                Capsule()
                            )


                        Spacer()


                        Button {

                            tasks.append(
                                TaskItem(
                                    priority: .low
                                )
                            )

                        } label: {

                            Image(
                                systemName: "plus"
                            )
                            .font(
                                .system(size: 20)
                            )
                        }

                        .buttonStyle(
                            .plain
                        )
                    }
                }
            }

            .listStyle(.plain)

            .scrollContentBackground(
                .hidden
            )
        }
    }



    // MARK: - TASK ROW

    @ViewBuilder
    private func taskRow(
        index: Int
    ) -> some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 20
            )

            .fill(
                Color("bubblecolor")
            )

            .frame(
                height: 70
            )


            HStack(
                spacing: 10
            ) {

                TextField(
                    "Enter task...",
                    text: $tasks[index].title
                )

                .strikethrough(
                    tasks[index].completed
                )

                .opacity(
                    tasks[index].completed
                    ? 0.5
                    : 1
                )


                DatePicker(
                    "",
                    selection:
                        $tasks[index].taskTime,
                    displayedComponents:
                        .hourAndMinute
                )

                .labelsHidden()


                Button {

                    tasks[index].completed.toggle()

                } label: {

                    Image(
                        systemName:
                            tasks[index].completed
                            ? "checkmark.circle.fill"
                            : "circle"
                    )

                    .font(
                        .system(size: 23)
                    )
                }

                .buttonStyle(
                    .plain
                )
            }

            .padding(
                .horizontal,
                20
            )
        }
    }



    // MARK: - FILTER TASKS

    private func filteredIndices(
        for priority: Priority
    ) -> [Int] {

        tasks.indices.filter { index in

            let task = tasks[index]

            guard task.priority == priority else {
                return false
            }

            return matchesFilter(task)
        }
    }



    // MARK: - MATCH FILTER

    private func matchesFilter(
        _ task: TaskItem
    ) -> Bool {

        switch taskFilter {

        case .all:

            return true


        case .completed:

            return task.completed


        case .incomplete:

            return !task.completed
        }
    }



    // MARK: - ADD SUGGESTED TASK

    private func addSuggestedTask(
        title: String,
        priority: Priority
    ) {

        tasks.append(
            TaskItem(
                title: title,
                priority: priority
            )
        )
    }
}



// MARK: - PREVIEW

#Preview {
    TaskPriorityGroupsView()
}
