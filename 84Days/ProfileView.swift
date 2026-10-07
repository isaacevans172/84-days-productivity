import SwiftUI
import SwiftData

struct ProfileView: View {

    @Query
    private var profiles: [LocalUserProfile]

    @Environment(\.dismiss)
    private var dismiss

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    private var profile: LocalUserProfile? {

        profiles.first
    }

    private var avatarName: String {

        profile?.avatar ?? "01-deadpan"
    }

    private var fullName: String {

        guard let profile else {
            return "Your Profile"
        }

        let name =
            "\(profile.firstName) \(profile.lastName)"
                .trimmingCharacters(
                    in: .whitespaces
                )

        return name.isEmpty
            ? "Your Profile"
            : name
    }

    var body: some View {

        List {

            // MARK: Profile

            Section {

                VStack(spacing: 12) {

                    Image(avatarName)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 105,
                            height: 105
                        )
                        .background(
                            Color(
                                .secondarySystemBackground
                            ),
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

                    Text(fullName)
                        .font(.system(
                            size: 20,
                            weight: .bold
                        ))

                    if let email = profile?.email {

                        Text(email)
                            .font(.system(size: 12))
                            .foregroundStyle(
                                .secondary
                            )
                    }
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 10)
            }

            // MARK: Journey

            Section("Journey") {

                LabeledContent(
                    "Journey",
                    value: "84 Days"
                )

                LabeledContent(
                    "Current streak",
                    value:
                        "\(profile?.currentStreak ?? 0) days"
                )

                LabeledContent(
                    "Longest streak",
                    value:
                        "\(profile?.longestStreak ?? 0) days"
                )

                LabeledContent(
                    "Daily goal",
                    value:
                        "\(profile?.dailyGoal ?? 3) tasks"
                )
            }

            // MARK: Progress

            Section("Your Journey") {

                NavigationLink {

                    ProgressView()

                } label: {

                    Label(
                        "Progress",
                        systemImage:
                            "chart.bar.fill"
                    )
                }

                NavigationLink {

                    GoalsView()

                } label: {

                    Label(
                        "Goals",
                        systemImage:
                            "target"
                    )
                }
            }

            // MARK: Settings

            Section("Settings") {

                NavigationLink {

                    Text("Notifications")
                        .navigationTitle(
                            "Notifications"
                        )

                } label: {

                    Label(
                        "Notifications",
                        systemImage: "bell"
                    )
                }

                NavigationLink {

                    Text("Appearance")
                        .navigationTitle(
                            "Appearance"
                        )

                } label: {

                    Label(
                        "Appearance",
                        systemImage:
                            "paintbrush"
                    )
                }
            }

            // MARK: About

            Section("About") {

                LabeledContent(
                    "App",
                    value: "84Days"
                )

                LabeledContent(
                    "Version",
                    value: "1.0"
                )
            }

            // MARK: Account

            Section {

                Button(
                    "Sign Out",
                    role: .destructive
                ) {

                    // Connect to the final
                    // Supabase auth flow here.
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(
                placement:
                    .confirmationAction
            ) {

                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
