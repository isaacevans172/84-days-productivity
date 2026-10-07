import SwiftUI

struct ContentView: View {

    @State private var selectedTab: AppTab = .home

    var body: some View {

        Group {

            switch selectedTab {

            case .home:

                NavigationStack {
                    HomeView()
                }

            case .todo:

                NavigationStack {
                    TasksView()
                }

            case .calendar:

                NavigationStack {
                    CalendarView()
                }

            case .focus:

                NavigationStack {
                    FocusPlaceholderView()
                }

            case .mascot:

                NavigationStack {
                    MascotHomeView()
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(
            Color(.systemBackground)
        )
        .safeAreaInset(
            edge: .bottom,
            spacing: 0
        ) {

            CustomTabBar(
                selectedTab: $selectedTab
            )
            .padding(.bottom, 4)
        }
    }
}

// MARK: - App Tab

enum AppTab {

    case home
    case todo
    case calendar
    case focus
    case mascot
}

// MARK: - Tab Bar

struct CustomTabBar: View {

    @Binding var selectedTab: AppTab

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    var body: some View {

        HStack(spacing: 2) {

            tabButton(
                tab: .home,
                title: "Home",
                icon: "house.fill"
            )

            tabButton(
                tab: .todo,
                title: "To-do",
                icon: "checkmark.square"
            )

            tabButton(
                tab: .calendar,
                title: "Calendar",
                icon: "calendar"
            )

            tabButton(
                tab: .focus,
                title: "Focus",
                icon: "circle.dashed"
            )

            mascotButton
        }
        .padding(7)
        .background(
            Color(.systemBackground),
            in: Capsule()
        )
        .overlay(
            Capsule()
                .stroke(
                    Color(.separator)
                        .opacity(0.25),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(0.08),
            radius: 12,
            y: 4
        )
        .padding(.horizontal, 12)
    }

    private func tabButton(
        tab: AppTab,
        title: String,
        icon: String
    ) -> some View {

        Button {

            withAnimation(
                .easeInOut(duration: 0.2)
            ) {
                selectedTab = tab
            }

        } label: {

            VStack(spacing: 4) {

                Image(systemName: icon)
                    .font(.system(
                        size: 20,
                        weight: .medium
                    ))

                Text(title)
                    .font(.system(
                        size: 10,
                        weight: .medium
                    ))
            }
            .foregroundStyle(
                selectedTab == tab
                ? .white
                : .secondary
            )
            .frame(
                maxWidth: .infinity
            )
            .frame(height: 58)
            .background {

                if selectedTab == tab {

                    Capsule()
                        .fill(.black)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var mascotButton: some View {

        Button {

            withAnimation(
                .easeInOut(duration: 0.2)
            ) {
                selectedTab = .mascot
            }

        } label: {

            ZStack {

                Circle()
                    .fill(
                        selectedTab == .mascot
                        ? coral.opacity(0.12)
                        : Color(.secondarySystemBackground)
                    )

                Image("18-happy")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
            .frame(
                width: 58,
                height: 58
            )
            .overlay(
                Circle()
                    .stroke(
                        selectedTab == .mascot
                        ? coral
                        : Color(.separator)
                            .opacity(0.25),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.leading, 4)
    }
}
