import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                TasksView()
            }
            .tabItem {
                Label("To-do", systemImage: "checkmark.square")
            }
            .tag(AppTab.todo)

            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(AppTab.calendar)

            NavigationStack {
                FocusView()
            }
            .tabItem {
                Label("Focus", systemImage: "circle.dashed")
            }
            .tag(AppTab.focus)

            NavigationStack {
                MascotHomeView()
            }
            .tabItem {
                Label("Mascot", systemImage: "face.smiling")
            }
            .tag(AppTab.mascot)
        }
    }
}

enum AppTab: Hashable {
    case home
    case todo
    case calendar
    case focus
    case mascot
}

#Preview {
    ContentView()
}
