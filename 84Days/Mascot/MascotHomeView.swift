//
//  MascotHomeView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI
import SwiftData

struct MascotHomeView: View {

    @Query
    private var profiles: [LocalUserProfile]

    @Query
    private var tasks: [TaskItem]

    @Query
    private var goals: [Goal]

    @State private var mascotState = MascotEngine.state(
        for: .openedApp
    )

    @State private var showingChat = false
    @State private var isGeneratingAI = false

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    private var profile: LocalUserProfile? {
        profiles.first
    }

    private var completedTasks: Int {
        tasks.filter {
            $0.isComplete
        }.count
    }

    private var progress: Double {

        guard !tasks.isEmpty else {
            return 0
        }

        return Double(completedTasks) /
            Double(tasks.count)
    }

    private var context: MascotContext {

        MascotContext(
            currentDay: 1,
            currentStreak: profile?.currentStreak ?? 0,
            longestStreak: profile?.longestStreak ?? 0,
            completedDays: 0,
            missedDays: 0,
            progressPercentage: progress * 100,
            milestoneName: nil,
            calendarInsight: nil,
            isFirstDay: true,
            returnedAfterAbsence: false
        )
    }

    var body: some View {

        ScrollView {

            VStack(
                spacing: 20
            ) {

                header

                MascotView(
                    state: mascotState
                )
                .frame(
                    maxWidth: .infinity
                )
                .padding(.top, 15)

                actionButtons

                statsCard

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .scrollIndicators(.hidden)
        .background(
            Color(.systemBackground)
        )
        .sheet(
            isPresented: $showingChat
        ) {
            NavigationStack {
                MascotChatView()
            }
        }
        .onAppear {
            updateMascot(
                event: .openedApp
            )
        }
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text("YOUR COMPANION")
                    .font(.system(
                        size: 10,
                        weight: .bold
                    ))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text("Mascot")
                    .font(.system(
                        size: 32,
                        weight: .bold
                    ))
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {

        VStack(spacing: 10) {

            Button {

                updateMascot(
                    event: .doingWell
                )

            } label: {

                HStack {

                    Image(
                        systemName: "sparkles"
                    )

                    Text("Check in with me")

                    Spacer()

                    Image(
                        systemName: "chevron.right"
                    )
                    .font(.system(size: 12))
                }
                .font(.system(
                    size: 14,
                    weight: .semibold
                ))
                .foregroundStyle(.primary)
                .padding(16)
                .background(
                    Color(.secondarySystemBackground),
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )
            }
            .buttonStyle(.plain)

            Button {

                showingChat = true

            } label: {

                HStack {

                    Image(
                        systemName: "bubble.left.and.bubble.right"
                    )

                    Text("Talk to your mascot")

                    Spacer()

                    Image(
                        systemName: "chevron.right"
                    )
                    .font(.system(size: 12))
                }
                .font(.system(
                    size: 14,
                    weight: .semibold
                ))
                .foregroundStyle(.primary)
                .padding(16)
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

    // MARK: - Stats

    private var statsCard: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("CURRENT CONTEXT")
                .font(.system(
                    size: 10,
                    weight: .bold
                ))
                .tracking(1)
                .foregroundStyle(.secondary)

            HStack {

                stat(
                    value: "\(completedTasks)",
                    label: "Tasks done"
                )

                Divider()
                    .frame(height: 35)

                stat(
                    value: "\(goals.count)",
                    label: "Goals"
                )

                Divider()
                    .frame(height: 35)

                stat(
                    value: "\(Int(progress * 100))%",
                    label: "Progress"
                )
            }
        }
        .padding(18)
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

    private func stat(
        value: String,
        label: String
    ) -> some View {

        VStack(spacing: 4) {

            Text(value)
                .font(.system(
                    size: 20,
                    weight: .bold
                ))

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity
        )
    }

    // MARK: - Mascot

    private func updateMascot(
        event: MascotEvent
    ) {

        mascotState = MascotEngine.state(
            for: event,
            context: context
        )
    }
}